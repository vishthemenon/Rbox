class Asset < ActiveRecord::Base
  attr_accessible :user_id, :uploaded_file
  belongs_to :user
  #Paperclip Setup
  has_attached_file :uploaded_file,
  					:url => "/assets/get/:id",
  					:path => ":rails_root/assets/:id/:basename.:extension"  
  validates_attachment_presence :uploaded_file

  def file_name
  	uploaded_file_file_name
  end

end
