
module HelperMethods
  def valid_session(opts = {})
    {
      :user_id => get_user('test').id.to_s
    }
  end


  def get_user(name, role = User::COMMON, ext = {})
    User.where(:username => name).first ||
    User.create({
      :username => name,
      :email => "#{name}@email.com",
      :role => role
    }.merge!(ext))
  end


  def error_should(res, e)
    JSON(res.body) == e.to_hash.merge(:ok => false)
  end
end