typeChangeHandler = function(event) {
    let fieldset = $(this).closest('fieldset')
    actualizeSelectors(fieldset)
}

nestedFormAddedHandler = function (event) {
    let addedForm = $(event.target).find("fieldset").last()
    let inputType = addedForm.find('.another_mentionable_type_input').first()
    inputType.on('change', typeChangeHandler)
    inputType.trigger('change')
}

actualizeSelectors = function (fieldset) {
    let inputType = fieldset.find('.another_mentionable_type_input').first()
    let selectedType = inputType.val()
    let inputId = fieldset.find('.another_mentionable_id_input').first()
    inputId.empty()
    fetchNewOptions(inputId, selectedType)
}

fetchNewOptions = function (input, selectedType) {
    let initialId = input.data('initial-id')
    let initialType = input.data('initial-type')

    $.ajax({
        url: '/admin/mentions/options_for_select',
        type: 'GET',
        dataType: "json",
        data: {
            mentionable_type: selectedType
        },
        success: (data) => {
            let newOptions = $.map(data.results, function(item) {
                let selected = (selectedType === initialType && item.id === initialId)
                return new Option(item.text, item.id, false, selected)
            })
            input.append(newOptions).trigger('change')
        }
    })
}

$(document).ready(function () {
    $(".has_many_container.mentions").on("has_many_add:after", nestedFormAddedHandler)

    $(".has_many_container.mentions fieldset").each(function() {
        let fieldset = $(this)
        let inputType = fieldset.find('.another_mentionable_type_input').first()
        inputType.on('change', typeChangeHandler)
        inputType.trigger('change')
    })
});
