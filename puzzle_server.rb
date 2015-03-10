
require 'rubygems'

require 'sinatra'

require 'coffee-script'

require 'json'

require 'pry'

set :server, %w[webrick thin mongrel]

set :port, 4566


get '/' do
  erb :index
end


get '/javascripts/puzzle.js' do
  coffee :puzzle
end


get '/puzzle-pattern' do
  @puzzle = PuzzlePattern.new
  pz = @puzzle.to_puzzle_string
  pz_obj = {pstring: pz}
  return pz_obj.to_json
end


before '/pz-photo' do
  photo_nums = ["005","033","143","156","165",
                "223","237","298","384","418",
                "476","531","547","636","661",
                "729","781","790","792","800",
                "808","813","820","831","836",
                "849","860","876"]
  num = photo_nums.sample
  # @photo_name = "/photos/hx#{num}.png"
  @photo_name = "hx#{num}.png"
  puts " ** before 'get pz-photo.png': filename = #{@photo_name}"
end


get '/pz-photo' do
  # send_file 'hx418.png'
  puts " "
  puts "**** get '/pz-photo'"
  puts "     filename = #{@photo_name}"
  puts " "
  send_file @photo_name, :filename => @photo_name, :type => :png
end


class PuzzlePattern

  SYM = [:a,:b,:c,:d,:e,:f,:g,:h,:i,:j,:k,:l,:m,:n,:o,:p]
  SIZES_START = [13,13,13,13,13,13,16,16,16,16,13,13,13,13,13,13]

  attr :pattern_string

  def initialize
    @grid = get_init_grid
    @piece_sizes = shuffle_piece_sizes
    build_piece_patterns
  end


  def build_piece_patterns
    init_all_rows
    complete_top_row
    complete_bottom_row
    mutate_vert_lanes
  end


  def init_all_rows
    [0,1,2].each {|rr| [0,1,2,3,4,5].each {|pc| [0,1,2,3].each {|i| set_hex(4*pc+i,rr,SYM[pc]) } } }
    [3,4,5].each {|rr| [6,7,8,9].each {|pc| [0,1,2,3,4,5].each {|i| set_hex(6*(pc-6)+i,rr,SYM[pc]) } } }
    [6,7,8,9].each {|pc| [1,3,5].each {|i| set_hex(6*(pc-6)+i,6,SYM[pc]) } }
    [6,7,8].each {|pc| set_hex(6*(pc-6)+6,4,SYM[pc]) }
    [10,11,12,13,14,15].each {|pc| [0,2].each {|i| set_hex(4*(pc-10)+i,6,SYM[pc]) } }
    [7,8].each {|rr| [10,11,12,13,14,15].each {|pc| [0,1,2,3].each {|i| set_hex(4*(pc-10)+i,rr,SYM[pc]) } } }
    [10,11,12,13,14,15].each {|pc| [1,3].each {|i| set_hex(4*(pc-10)+i,9,SYM[pc]) } }
  end


  def get_init_grid
    grid = []
    0.upto(9) do
      row = []
      24.times {|cc| row << :x}
      grid << row
    end
    0.step(22,2) {|cx| grid[9][cx] = :z}
    grid
  end


  def complete_top_row
    top = @piece_sizes[0..5]
    0.upto(5) {|pc| augment_top_piece(pc,SYM[pc],top[pc]) }
  end


  def augment_top_piece(pc,sym,size)
    if size == 13
      i = rand(2)*2
      set_hex(4*pc+1+i,3,sym)
    end
    if size == 15
      k = rand(2)*2
      4.times {|i| set_hex(4*pc+i,3,sym) unless i == k}
    end
  end


  def complete_bottom_row
    bottom = @piece_sizes[10..15]
    10.upto(15) {|pc| augment_bottom_piece(pc,SYM[pc],bottom[pc-10]) }
  end


  def augment_bottom_piece(pc,sym,size)
    if size == 13
      i = 1+rand(2)*2
      set_hex(4*(pc-10)+i,6,sym)
    end
    if size == 15
      [1,3].each {|i| set_hex(4*(pc-10)+i,6,sym) }
      i = rand(2)*2
      set_hex(4*(pc-10)+i,5,sym)
    end
  end


  def mutate_vert_lanes
    boundaries = [0,1,2,3,4,10,11,12,13,14].shuffle[0..5]
    boundaries.each {|pc_1| mutate_lanes(pc_1)}
  end


  def mutate_lanes(pc_1)
    pc_2 = pc_1+1
    rows = pc_1 < 10 ? [0,1,2] : [7,8,9]
    rows.shuffle!
    row_1 = rows[2]
    z = rand(2)
    row_2 = rows[z]
    row_2 = row_2-1 if pc_1 >= 10
    col = pc_1 < 10 ? 4*pc_1+3 : 4*(pc_1-10)+3
    set_hex(col,row_1,SYM[pc_2])
    set_hex(col+1,row_2,SYM[pc_1])
  end


  def shuffle_piece_sizes
    sizes = SIZES_START
    fifteens = 0
    until fifteens == 4 do
      r6 = rand(6)
      if not (sizes[r6] == 15 || sizes[r6+10] == 15)
        r2 = rand(2)
        sizes[r6+10*r2] = 15
        fifteens = fifteens+1
      end
    end
    sizes
  end


  def set_hex(aa,bb,sym)
    @grid[bb][aa] = sym
  end


  def to_puzzle_string
    str = ""
    @grid.each {|row| row.each {|hx| str << hx.to_s} }
    str
  end

end



def puzzle_string
  @puzzle = PuzzlePattern.new
  @puzzle.to_dom_string
end
