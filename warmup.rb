class Object
  def new_attr_accessor(*attrs)
    attrs.each do |attribute|

      attr_str = attribute.to_s
      attr_sym = "@#{attr_str}".to_sym

      define_method(attr_str) do
        instance_variable_get(attr_sym)
      end

      define_method("#{attr_str}=") do |value|
        instance_variable_set(attr_sym, value)
      end
    end
  end

end

class Cat
  new_attr_accessor :name, :color
end