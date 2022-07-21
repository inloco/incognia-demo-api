// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "channels"
import "controllers"

window.onload = function() {
  var arrows = document.querySelectorAll(".topbar .user .arrow")
  var dropdown = document.querySelector(".topbar .user .dropdown")

  arrows.forEach((arrow) => {
    arrow.addEventListener("click", function(e){
      arrows.forEach((a) => {
        a.classList.toggle("hide");
      });

      dropdown.classList.toggle("active");
    });
  });
};
