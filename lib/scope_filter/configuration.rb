# encoding: utf-8

module ScopeFilter
  
  class Configuration
    
    attr_reader :fields, :scopes, :sort_fields
    
    def initialize
      @fields = {}
      @scopes = {}
      @sort_fields = []
    end
    
    def add_field(field, cop, options = {})
      pattern = options[:pattern]
      @fields[field.to_sym] = { :condition => "#{options[:field] ? options[:field] : field} #{cop}#{pattern ? ' ?' : ''}", :pattern => pattern }
    end
    
    def add_scope(name, arg = false)
      @scopes[name.to_sym] = { :arg => arg }
    end
    
    def add_scopes(*scopes)
      arg = scopes.delete_at(scopes.size-1) if scopes.last.is_a?(TrueClass) || scopes.last.is_a?(FalseClass)
      scopes.each { |s| add_scope(s, arg.nil? ? false : arg) }
    end
    
    def method_missing(m, *args, &block)
      field = args.first.to_sym
      options = args.second || {}
      idx = %w(eq g gt l lt neq like ilike).index(m.to_s)
      if idx
        comp = %w(= > >= < <= <> LIKE ILIKE)[idx]
        add_field field, comp, add_default_pattern(comp, options)
      end
      add_field field, 'IS NULL', options if m == :null
      add_field field, 'IS NOT NULL', options if m == :not_null
    end
    
    def sortable(*fields)
      @sort_fields += fields.map(&:to_sym)
    end
    
    private 
    
    def add_default_pattern(comp, options)
      return options if options[:pattern]
      options.merge(:pattern => lambda { |v| comp =~ /LIKE/ ? "%#{v}%" : v })
    end
    
  end
  
end
