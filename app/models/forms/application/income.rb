module Forms
  module Application
    class Income < ::FormObject
      def self.permitted_attributes
        {
          income: Integer,
          dependents: Boolean,
          children: Integer
        }
      end

      define_attributes

      validates :income, presence: true
      validates :income, presence: true,
                         numericality: { allow_blank: true, greater_than: 0 }

      validates :dependents, inclusion: { in: [true, false] }
      validates :children, numericality: { greater_than: 0, only_integer: true }, if: :dependents?
      validate :number_of_children_when_no_dependents

      private

      def number_of_children_when_no_dependents
        if children_declared_but_dependents_arent?
          errors.add(
            :children,
            :cant_have_children_assigned
          )
        end
      end

      def children_declared_but_dependents_arent?
        !dependents && children.to_i.positive?
      end

      def persist!
        @object.update(fields_to_update)
      end

      def fields_to_update
        {
          income: income,
          dependents: dependents,
          children: children,
          application_type: 'income'
        }
      end
    end
  end
end
