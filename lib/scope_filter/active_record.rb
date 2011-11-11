# encoding: utf-8
require_relative 'configuration'

module ScopeFilter
  module ActiveRecord
    
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
    
      def configure_scope_filter(&block)        
        @@sf_config = Configuration.new
        
        yield @@sf_config
        
        def self.scope_filter(values = {})
          init_scope = self.scoped
          if sort = values.delete(:_sort)
            sort_field, sort_dir = sort.to_s.split('_')
            init_scope = self.order("#{sort_field} #{sort_dir.upcase}") if @@sf_config.sort_fields.include?(sort_field.to_sym)
          end
          values.inject(init_scope) do |rel, q|
            field = q.first.to_sym
            value = q.last
            return rel if value.blank?
            if cond = @@sf_config.fields[field]
              rel = rel.where(cond[:condition], cond[:pattern] ? cond[:pattern].call(value) : value)
            elsif cond = @@sf_config.scopes[field]
              rel = cond[:arg] ? rel.send(field, value) : rel.send(field)
            else
              rel
            end
          end
        end
        
      end
      
    end
    
  end
end
