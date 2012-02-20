module UsersHelper

  def gravatar_for(user, options = { :size => 50})
    gravatar_image_tag(user.email.downcase, :alt => h(user.name), #h is for html_escape since not done on alt by default
                                            :class => 'gravatar',
                                            :gravatar => options)
  end
end
