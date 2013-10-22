class MassObject
  def self.my_attr_accessible(*attributes)

    attributes.each do |attribute|
      attr_accessor attribute
    end

    @attributes = attributes
  end

  def self.attributes
    @attributes
  end

  def self.parse_all(results)
    results.map { |hash| new(hash) }
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      
      if self.class.attributes.include?(attr_name.to_sym)
        ivar = "@#{attr_name.to_s}".to_sym
        instance_variable_set(ivar, value)
      end
    end
  end
end
