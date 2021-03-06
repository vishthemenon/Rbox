class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, . :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :firstname, :lastname, :username, :email, :password, :password_confirmation, :remember_me
  
  validates_presence_of :firstname, :lastname, :username, :email, :password
  validates_uniqueness_of :username, :email
  validates_length_of :password, :minimum => 5, :message => "Sorry, your password is too short."
  validates_length_of :username, :in => 5..15, :message => "Sorry, your username has to be 5-20 characters long." 

  has_many :authentications, :dependent => :delete_all
  has_many :assets
  has_many :folders

  #this is for folders which this user has shared  
  has_many :shared_folders, :dependent => :destroy  
    
  #this is for folders which the user has been shared by other users  
  has_many :being_shared_folders, :class_name => "SharedFolder", :foreign_key => "shared_user_id", :dependent => :destroy  
  
  def apply_omniauth(auth)
    # In previous omniauth, 'user_info' was used in place of 'raw_info'
    self.email = auth['extra']['raw_info']['email']
    # Again, saving token is optional. If you haven't created the column in authentications table, this will fail
    authentications.build(provider: auth['provider'], uid: auth['uid'], token: auth['credentials']['token'])
  end

  after_create :check_and_assign_shared_ids_to_shared_folders  
    
  #this is to make sure the new user ,of which the email addresses already used to share folders by others, to have access to those folders  
  def check_and_assign_shared_ids_to_shared_folders      
      #First checking if the new user's email exists in any of ShareFolder records  
      shared_folders_with_same_email = SharedFolder.find_all_by_shared_email(self.email)  
    
      if shared_folders_with_same_email        
        #loop and update the shared user id with this new user id   
        shared_folders_with_same_email.each do |shared_folder|  
          shared_folder.shared_user_id = self.id  
          shared_folder.save  
        end  
      end      
  end  
end
