unless Object::keys
  Object::keys = () ->
    Object.keys(this)
