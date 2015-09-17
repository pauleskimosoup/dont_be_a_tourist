class FrameController < ApplicationController

  def video_frame
    @video = Video.find(params[:video])
  end

end
