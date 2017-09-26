class SelectPickerInput < SimpleForm::Inputs::Base
  def input
    collection = Collection::LIST

    label_method = :to_s
    value_method = :to_s

    @builder.collection_select(
      attribute_name, collection, value_method, label_method,
      input_options, input_html_options
    )
  end

  def input_html_classes
    super.push('selectpicker')
  end

end
