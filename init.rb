ActiveRecord::Reflection::ThroughReflection.send(:include, HasManyThroughHabtm::ThroughReflection)
ActiveRecord::Associations::HasManyThroughAssociation.send(:include, HasManyThroughHabtm::HasManyThroughAssociation)