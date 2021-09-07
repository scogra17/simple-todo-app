$(function() {

  $("form.delete").submit(function(event) {
    event.preventDefault();
    event.stopPropagation();

<<<<<<< HEAD
    var ok = confirm("Are you sure? This cannot be undone!");
    if (ok) {
=======
    var ok = confirm("Are you sure? This cannot be undone.");
    if (ok) {
      // this.submit();
>>>>>>> fe6d29f363b93e31fc753d452dc70ed91a6fd726
      var form = $(this);

      var request = $.ajax({
        url: form.attr("action"),
        method: form.attr("method")
<<<<<<< HEAD
      });

      request.done(function(data, textStatus, jqXHR) {
        if (jqXHR.status == 204) {
          form.parent("li").remove();
        } else if (jqXHR.status == 200) {
          document.location = data;
        }
      });
    }
  });

});
=======
      })


      request.done(function(data, textStatus, jqXHR) {
        if (jqXHR.status === 204) {
          form.parent("li").remove()
        } else if (jqXHR.status === 200) {
          document.location = data;
        }
      })
    }
  });
});
>>>>>>> fe6d29f363b93e31fc753d452dc70ed91a6fd726
