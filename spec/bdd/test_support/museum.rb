module Page
  class Museum
    include Capybara::DSL

    WEEK = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']

    def initialize
      url = '/museum'
      visit(url)
      validate!
    end

    def click_new_museum
      find('#newMuseum').click
    end

    def has_sidebar?
      has_css?('#listing')
    end

    def has_form?
      has_css?('#formulary')
    end

    def fill_input(field, content)
      fill_in(field, with: content)
    end

    def save_enabled?
      has_css?('.submit:enabled')
    end

    def save_disabled?
      has_css?('.submit:disabled')
    end

    def submit
      find('#saveMuseum').click
    end

    def click_edit_button
      has_css?('.edit-button', wait: 2)
      find('.edit-button').click
    end

    def has_info?(content)
      has_content?(content)
    end

    def has_field_value?(field, value)
      (find_field(field).value == value)
    end

    def has_edit_button?
      has_css?('.edit-button')
    end

    def shows_info?
      has_css?('.view')
    end

    def add_input(type)
      find(type).click
    end

    def button_enabled?(css_class)
      button = find(css_class)
      result = button[:disabled]

      return true if result.nil?

      false
    end

    def has_extra_input?(actual_inputs = 1)
      inputs = all("input[name^='phone']")
      inputs.size > actual_inputs
    end

    def remove_field_content
      fill_in('link', with: '')
    end

    def introduce_hours(range)
      fill_in('openingHours', with: range)
    end

    def click_checkbox(day)
      find_field(name: day).click
    end

    def lose_focus
      submit
    end

    def editable_name
      find('[name=name]').value
    end

    def edit_hour(hour)
      element = first('.editable-hour')
      element.send_keys(:end)
      (0..hour.length).each do |i|
        element.send_keys(:backspace)
      end
      element.send_keys(hour)
    end

    def remove_added_input(name)
      element = find("[name=#{name}]")
      element.send_keys(:end)
      (0..element.value.length).each do |i|
        element.send_keys(:backspace)
      end
    end

    def edited_hour
      first('.editable-hour').text
    end

    def has_field?(name)
      find("[name=#{name}]").value
    end

    def all_fields_checked?
      WEEK.each do |day|
        if day_unchecked?(day)
          return false
        end
      end
      true
    end

    def day_unchecked?(day)
      !has_checked_field?(day)
    end

    def click_add_hour
      find('.add-button.cuac-schedule-hours').click
    end

    def hours_field_empty?
      hours_field = find('[name=openingHours]').value
      hours_field.length == 0
    end

    def focus_in_input?(name)
      focus = evaluate_script('document.activeElement.name')
      name == focus
    end

    def fill_with_bad_link
      bad_link = "https://www.google.es/maps/place/Museo+Guggenheim+Bilbao/"
      fill_in('link', with: bad_link)
    end

    def fill_with_good_link
      good_link = "https://www.google.es/maps/place/Institut+Valenci%C3%A0+d'Art+Modern/@39.4723137,-0.3909856,15z"
      fill_in('link', with: good_link)
    end

    def change_focus
      find('[name=region]').click
    end

    def go_to_museum_info(museum_name)
      has_css?('.museum-name', wait: 6, text: museum_name)
      find('.museum-name', text: museum_name, visible: true).click
    end
    private

    def validate!
      assert_selector('#formulary', visible: false)
      assert_selector('#result', visible: false)
      assert_selector("input[name='name']", visible: false)
      assert_selector("input[name='street']", visible: false)
      has_no_css?('.has-error')
    end
  end
end
