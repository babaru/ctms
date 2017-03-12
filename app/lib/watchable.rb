module Watchable
  def watch(user)
    if watched?(user)
      users.delete(user)
    else
      users << user
    end
  end

  def unwatched?(user)
    !watched?(user)
  end

  def watched?(user)
    users.include?(user)
  end
end
