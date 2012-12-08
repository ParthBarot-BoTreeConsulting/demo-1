$(document).ready(function(){
    $('#id_find').live('click', function(){
        var zipcode = $('#id_zipcode').val();
        var range = $('#id_range').val();

        if(zipcode.trim() == ""){
            alert("Please Enter a Zipcode.");
            return;
        }else if(range.trim() == ""){
            alert("Please enter Range in miles.");
            return;
        }else if(isNaN(range)){
            alert("Please enter a Number in Range field.");
            return;
        }

        $.ajax({
            cache: false,
            type: 'POST',
            url: '/locations/find',
            data: {
                zipcode: zipcode,
                range: range
            },
            beforeSend: function(){
                $('#search_results').html("")
                $('#loader').show();
            },
            complete: function(){
                $('#loader').hide();
            }
        });
    });
});