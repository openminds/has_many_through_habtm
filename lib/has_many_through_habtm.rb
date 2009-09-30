# HasManyThroughHabtm
module HasManyThroughHabtm
  module ThroughReflection
    def self.included(base)
      base.alias_method_chain :check_validity!, :habtm
    end

    def check_validity_with_habtm!
      check_validity_without_habtm!
    rescue ActiveRecord::HasManyThroughSourceAssociationMacroError
      raise unless source_reflection.macro == :has_and_belongs_to_many
    end
  end

  module HasManyThroughAssociation
    def self.included(base)
      base.alias_method_chain :construct_joins, :habtm
      base.alias_method_chain :construct_conditions, :habtm
    end

    def construct_conditions_with_habtm
      if @reflection.through_reflection.macro == :has_and_belongs_to_many
        table_name = @reflection.through_reflection.options[:join_table]
        conditions = construct_quoted_owner_attributes(@reflection.through_reflection).map do |attr, value|
          "#{table_name}.#{attr} = #{value}"
        end
        conditions << sql_conditions if sql_conditions
        "(" + conditions.join(') AND (') + ")"
      else
        construct_conditions_without_habtm
      end
    end

    def construct_joins_with_habtm(custom_joins = nil)
      if @reflection.source_reflection.macro == :has_and_belongs_to_many
        "INNER JOIN %s ON %s.%s = %s.%s INNER JOIN %s ON %s.%s = %s.%s #{@reflection.options[:joins]} #{custom_joins}" % [
          @reflection.source_reflection.options[:join_table],
          @reflection.source_reflection.options[:join_table], @reflection.source_reflection.association_foreign_key,
          @reflection.source_reflection.table_name, @reflection.source_reflection.klass.primary_key,

          @reflection.through_reflection.quoted_table_name,
          @reflection.source_reflection.options[:join_table], @reflection.source_reflection.primary_key_name,
          @reflection.through_reflection.quoted_table_name, @reflection.klass.primary_key
        ]
      elsif @reflection.through_reflection.macro == :has_and_belongs_to_many
        construct_joins_without_habtm(custom_joins) + " INNER JOIN %s ON %s.%s = %s.%s" % [
          @reflection.through_reflection.options[:join_table].inspect,
          @reflection.through_reflection.options[:join_table].inspect, @reflection.through_reflection.association_foreign_key,
          @reflection.through_reflection.quoted_table_name, @reflection.through_reflection.klass.primary_key
        ]
      else
        construct_joins_without_habtm(custom_joins)
      end
    end
  end
end