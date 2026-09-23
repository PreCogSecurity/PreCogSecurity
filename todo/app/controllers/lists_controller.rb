class ListsController < ApplicationController
  def create
    @list = List.new(list_params)
    if @list.save
      flash[:notice] = "Your list was created"
      redirect_to(list_tasks_url(@list))
    else
      # Redirect to the root instead of building a URL from an unsaved record
      # (nil id), which would raise a routing error.
      flash[:alert] = "There was an error creating your list."
      redirect_to(root_url)
    end
  end

  def destroy
    @list = List.find(params[:id])
    @list.destroy

    respond_to do |format|
      format.html { redirect_to(root_url) }
      format.json { render :json => { :status => 'success' } }
    end
  end

  private

  def list_params
    params.require(:list).permit(:name)
  end
end