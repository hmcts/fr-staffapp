class PathStorage

  def initialize(user)
    @user_key = "application-path-#{user.id}"
  end

  def navigation(current_path)
    @current_path = current_path
    return if load_last == @current_path

    if current_path_in_the_list
      remove_path_from_list
    else
      add_path_to_list
    end
  end

  def path_back
    load_previous
  end

  def clear!
    storage.set(@user_key, nil)
  end

  private

  def storage
    # if REDIS_URL is nil it will use the default address
    @storage ||= Redis.new(url: ENV.fetch("REDIS_URL", nil))
  end

  def load_navigation_list
    storage_value = storage.get(@user_key)
    list = storage_value.blank? ? '[]' : storage.get(@user_key)
    @navigation_list = JSON.parse(list)
  end

  def add_path_to_list
    @navigation_list << @current_path
    storage.set(@user_key, @navigation_list.to_json)
  end

  def remove_path_from_list
    @navigation_list.reverse_each do |path_in_the_list|
      break if path_in_the_list == @current_path
      @navigation_list.pop
    end

    storage.set(@user_key, @navigation_list.to_json)
  end

  def load_previous
    case load_navigation_list.size
    when 0..1
      return ''
    when 2
      position = 0
    else
      position = load_navigation_list.size - 2
    end

    @navigation_list[position]
  end

  def load_last
    load_navigation_list.last
  end

  def current_path_in_the_list
    load_navigation_list.include?(@current_path)
  end

end
