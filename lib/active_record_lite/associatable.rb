require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  attr_reader :other_class_name, :primary_key, :foreign_key
  
  def other_class
    @other_class_name.constantize
  end

  def other_table_name
    other_class.table_name
  end
end

class BelongsToAssocParams < AssocParams
  
  def initialize(name, params)
    @other_class_name = params[:class_name] || name.to_s.camelize
    @primary_key = params[:primary_key] || :id
    @foreign_key = params[:foreign_key] || "#{name}_id".to_sym;
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
    @other_class_name = params[:class_name] || name.to_s.singularize.camelize
    @primary_key = params[:primary_key] || :id
    @foreign_key = params[:foreign_key] || "#{self_class.name.underscore}_id".to_sym;
  end

  def type
  end
end

module Associatable
  def assoc_params
    @assoc_params ||= {}
    @assoc_params
  end

  def belongs_to(name, params = {})
    aps = BelongsToAssocParams.new(name, params)
    
    assoc_params[name] = aps
    
    define_method("#{name}") do 
      sql = <<-SQL
              SELECT 
                * 
              FROM 
                #{aps.other_table_name} 
              WHERE
                #{aps.other_table_name}.#{aps.primary_key} = ?
              LIMIT 1  
            SQL
            
        aps.other_class.parse_all(DBConnection.execute(sql, self.send(aps.foreign_key))).first
    end    
  end

  def has_many(name, params = {})
    aps = HasManyAssocParams.new(name, params, self)
    
    assoc_params[name] = aps
    
    define_method("#{name}") do 
      sql = <<-SQL
              SELECT 
                * 
              FROM 
                #{aps.other_table_name} 
              WHERE
                #{aps.other_table_name}.#{aps.foreign_key} = ?
            SQL
            
        aps.other_class.parse_all(DBConnection.execute(sql, self.send(aps.primary_key)))
    end
  end

  def has_one_through(name, assoc1, assoc2)
           
    define_method("#{name}") do
      assoc1 = self.class.assoc_params[assoc1]      
      assoc2 = assoc1.other_class.assoc_params[assoc2]
     
      sql = <<-SQL
              SELECT 
                #{assoc2.other_table_name}.* 
              FROM 
                #{assoc2.other_table_name}
              JOIN
                #{assoc1.other_table_name}
              ON
                #{assoc2.other_table_name}.#{assoc2.primary_key} = #{assoc1.other_table_name}.#{assoc2.foreign_key}
              WHERE
                #{assoc1.other_table_name}.#{assoc1.primary_key} = ?
              LIMIT 1
            SQL
                
      assoc2.other_class.parse_all(DBConnection.execute(sql, self.send(assoc1.foreign_key))).first
    end
  end
end
