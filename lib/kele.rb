require 'httparty'
require 'json'
require './lib/roadmap.rb'

class Kele
  include HTTParty
  include Roadmap
  base_uri 'https://www.bloc.io/api/v1'

  def initialize(email, password)
    response = self.class.post('/sessions', body: { "email": email, "password": password} )
    raise "Cannot authenticate: Invalid email/password" if response.code != 200
    @auth_token = response["auth_token"]
  end

  def get_me
    response = self.class.get('/users/me', headers: { "authorization" => @auth_token })
    @user = JSON.parse(response.body)
  end

  def get_mentor_availability(mentor_id)
    response = self.class.get("/mentors/#{mentor_id}/student_availability", headers: { "authorization" => @auth_token })
    @mentor_availability = JSON.parse(response.body)
  end

  def get_messages(page_num = nil)
    if page_num == nil
      response = self.class.get("/message_threads/", headers: { "authorization" => @auth_token })
    else
      response = self.class.get("/message_threads?page=#{page_num}", headers: { "authorization" => @auth_token })
    end
    @messages = JSON.parse(response.body)
  end

  def create_message(msg_sender, msg_recipient_id, msg_subject, msg_text)
    response = self.class.post("/messages",
      headers: { "authorization" => @auth_token },
      body: {
        "sender" => msg_sender,
        "recipient_id" => msg_recipient_id,
        "subject" => msg_subject,
        "stripped-text" => msg_text
      })
  end

  def create_submission(assign_branch, assign_commit_link, check_id, assign_comment, enroll_id)
    response = self.class.post("/checkpoint_submissions",
      headers: { "authorization" => @auth_token },
      body: {
        "assignment_branch" => assign_branch,
        "assignment_commit_link" => assign_commit_link,
        "checkpoint_id" => check_id,
        "comment" => assign_comment,
        "enrollment_id" => enroll_id
      })
    @checkpoint = JSON.parse(response.body)
  end

  def update_submission(id, assign_branch, assign_commit_link, check_id, assign_comment, enroll_id)
    response = self.class.put("/checkpoint_submissions/#{id}",
      headers: { "authorization" => @auth_token },
      body: {
        "assignment_branch" => assign_branch,
        "assignment_commit_link" => assign_commit_link,
        "checkpoint_id" => check_id,
        "comment" => assign_comment,
        "enrollment_id" => enroll_id
      })
    @update_check = JSON.parse(response.body)
  end
end
