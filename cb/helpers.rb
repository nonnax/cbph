#!/usr/bin/env ruby
# Id$ nonnax 2021-11-29 13:16:03 +0800
require 'rubytools/cubadoo'
require 'rubytools/array_ext'

keys=%i[rec_id image_url username location age current_show is_hd is_new num_users num_followers chat_room_url_revshare]
REC_ID, IMAGE_URL, USERNAME, LOCATION, AGE, CURRENT_SHOW, IS_HD, IS_NEW, NUM_USERS, NUM_FOLLOWERS, CHAT_ROOM_URL_REVSHARE = *(0..keys.size)
OFFSET=54
NEW = '⭐️'
OLD = '❤️'
# TITLE = '░c░a░m░o░h░o░l░i░c░s░+░a░n░o░n░y░m░o░u░s░'
# TITLE = '░░camoholics░░anonymous░░'
# TITLE = '𝕔𝕒𝕞𝕠𝕙𝕠𝕝𝕚𝕔𝕤+𝕒𝕟𝕠𝕟𝕪𝕞𝕠𝕦𝕤'
TITLE = '𝕔𝕒𝕞+𝕠+𝕙𝕠𝕝𝕚𝕔𝕤+𝕒𝕟𝕠𝕟𝕪𝕞𝕠𝕦𝕤'


Cuba.class_eval do
  def _layout(&block)
    groups={
      newbies: '/newbies/1/0',
      hd: '/hd/1/0',
      teen:'/group/1/teen',
      '20s' => '/group/1/20s',
      '25up' => '/group/1/25up',
      '30up' => '/group/1/30up',
      others:  '/group/1/others',
      pick: '/pickph/1/0'
    }
    root_path, page, q = req.path

    html_ do
      head_ do
        meta_('http-equiv': 'refresh', content: '120')
        # link(rel: 'stylesheet', type: "text/css",  href: '/css/style.css')
        link_(rel: 'stylesheet', type: 'text/css', href: '/css/style001.css')
      end
      body_ do        
        div_( id: 'banner') do
          ul_( id: 'home' ){
            li_ {a_( href: '/'){img_ id: 'logo', src: '/media/ca_eye.png'}}
            li_ {a_( href: '/'){h3_ { TITLE } }}
            li_ {span_{%(: Hi I'm X, and I'm a cam-o-holic :::...)}}
          }          
          div_( id: 'search' ) do
            div_(class: 'new') do
              ul_ do
                groups.each do |k, v|
                  class_name = root_path.match(k.to_s) ? 'current_page' : 'page'
                  li_{a_(class: class_name, href: v){ k }} 
               end
              end
            end
            div_(class: 'form') do
              form_(action: '/search', method: 'get') do
                input_(type: 'text', name: 'q' )
                input_(type: 'submit', value: 'q')
              end
            end
          end
        end
        div_(id: 'content', &block)
      end
    end
  end

  def location_links(rooms)
    div_(class: 'location') do
      rooms.map { |r| r[LOCATION] }.uniq.map do |loc|
        a_(class: 'page', href: "/search/1/#{loc}") { loc }
      end
    end
  end

  def page_info(page, pages)
    div_ do
      "(#{page + 1} of #{pages})"
    end
  end

  def montage(vrooms, page, offset = OFFSET)
    rooms = vrooms.uniq.sort_by { |r| r[NUM_FOLLOWERS].to_i }.reverse
    div_ do
      page_start = (page * offset)
      rooms[(page_start)..(page_start + offset - 1)].map do |u|
          rec_id, image_url, username, location, age, current_show, is_hd, is_new, num_users, num_followers, chat_room_url_revshare = u
            div_(class: 'grid') do
              div_(class: 'center') do
                a_(href: "/room/#{rec_id}", target: '_blank') do
                  img_(src: image_url)
                end
              end
              div_(class: 'user') do
                ul_(class: 'basic') do
                  li_ { username }
                  li_ { location }
                end
                ul_(class: 'extra') do
                  li_ { is_new=='true' ? NEW : OLD}
                  li_ { num_followers }
                  li_ { a_( href: "/pick/#{username}"){'+'} }
                  
                end
              end
            end
      end
    end
  end

  def _pagination(page=1, pages=10)
      path_root, path_page, q, = req.path.scan(/\w+/)
      tagz do
         div_(class: 'pages') do
            if pages.zero?
              span_(class: 'page'){'1'}
            else
              (1..pages).to_a.window(at: page, take: 10).each do |pg|
                href_path = q ? "/#{path_root}/#{pg}/#{q}" : "/#{path_root}/#{pg}"
                page==pg-1 ? span_(class: 'current_page'){ pg } : a_(class: 'page', href: href_path) { b_{ pg } }
              end
            end
          end
      end  
  end
  
  def render_rooms(vrooms, pg = 1, q = '', offset = OFFSET)
    rooms = vrooms
    page = pg.to_i - 1    
    pages = (rooms.size / offset.to_f).floor
    _links = location_links(rooms)
    _montage_view = montage(rooms, page)
    req_base, req_page, req_q = req.path.scan(/\w+/)

    _pagination_pages=_pagination(page, pages)
    
    render(layout: true) do
      div_ do
        p_{ _pagination_pages }
        p_{ _montage_view }
        div_(class: 'clearfix') { hr_ }
        p_{ _pagination_pages}
        p_{ _links }
      end
    end
  end

  def datastore
    dbfile='./data.csv'
    CSV.read(dbfile)
  end

  def pick_toggle(username)
    Thread.new do
      plist=data_picklist
      plist.include?(username) ? plist.delete(username) : plist.push(username) 
      File.write('picklist', plist.join("\n"))
      sleep 1
    end.join
  end
  
  def data_picklist
    File.read("picklist").split("\n")
  end
    
end
