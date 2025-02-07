$(document).ready(function () {
    $('.autocomplete-select').each(function( _index ) {
        let selector = $(this)
        let id = selector.attr('id')
        let delay = selector.data('autocomplete-delay') || 500
        let url = selector.data('autocomplete-url') || alert(`data-autocomplete-url not filled for #${id}`)

        selector.select2({
            minimumInputLength: 3,
            ajax: {
                delay: delay,
                url: url,
                dataType: 'json',
                processResults: function (data) {
                    return {
                        results: data.results
                    };
                }
            }
        });
    });
});
