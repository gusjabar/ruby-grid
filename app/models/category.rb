class Category < ActiveRecord::Base
  paginates_per 3
  filterrific(
      default_filter_params: {sorted_by: 'created_at_desc'},
      available_filters: [
          :sorted_by,
          :search_query
      ]
  )

  scope :search_query, lambda { |query|
    # Filters students whose name or email matches the query
    return nil if query.blank?

    # condition query, parse into individual keywords
    terms = query.downcase.split(/\s+/)

    # replace "*" with "%" for wildcard searches,
    # append '%', remove duplicate '%'s
    terms = terms.map { |e|
      (e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }
    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conds = 1
    where("LOWER(categories.Name) LIKE ? ", terms)


  }
  scope :sorted_by, lambda { |sort_option|
    # Sorts students by sort_key

    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^created_at_/
        # Simple sort on the created_at column.
        # Make sure to include the table name to avoid ambiguous column names.
        # Joining on other tables is quite common in Filterrific, and almost
        # every ActiveRecord table has a 'created_at' column.
        order("categories.created_at #{ direction }")
      when /^name_/
        # Simple sort on the name colums
        order("LOWER(categories.name) #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end

  }

  def self.options_for_sorted_by
    [
        ['Name (a-z)', 'name_asc'],
        ['Created date (newest first)', 'created_at_desc'],
        ['Created date (oldest first)', 'created_at_asc']
    ]
  end

  def self.options_for_select
    order('name').map { |e| [e.name, e.id] }
  end

end