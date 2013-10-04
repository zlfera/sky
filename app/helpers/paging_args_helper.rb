
module PagingArgsHelper
  def paging_args
    perpage = params[:perpage].to_i
    perpage = 10 if perpage == 0

    page = params[:page].to_i || 1

    args = {
      :page => page,
      :perpage => perpage,
      :limit => perpage
    }
    args[:skip] = (page - 1) * perpage if page > 1

    args
  end
end