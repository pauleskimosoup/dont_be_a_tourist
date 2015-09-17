
function show_picture(picture) {
  if (!(current_picture==picture)) {
    run_slide_show = false;
    Effect.Fade($("slideshow_image_" + current_picture));
    Effect.Appear($("slideshow_image_" + picture));
    current_picture = picture;
  }
};

new PeriodicalExecuter(
  function() {
    if (run_slide_show) {
      previous_picture = current_picture;
      current_picture = (current_picture + 1) % num_pictures;
      Effect.Fade($("slideshow_image_" + previous_picture));
      Effect.Appear($("slideshow_image_" + current_picture));
    };
  }, 4);


