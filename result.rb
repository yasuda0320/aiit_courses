require 'open-uri'
require 'pdf-reader'
require_relative 'recommended_courses'
require_relative 'course2020'

################################################################################
# 成績スクレイピングクラス
################################################################################
class Result
  ################################################################################
  # 定数
  ################################################################################
  DISCLOSURE = 'https://aiit.ac.jp/support/disclosure.html'
  PDF_REGEXP = %r(href="(/documents/jp/support/disclosure/.*\.pdf)")
  RESULT_REGEXP = /\s+(\S{3,}|\w\S+ \S+|\w\S+ \S+ \S+|\w\S+ \S+ \S+ \S+)\s+(\S{3,}|\w+ \w+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/
  RESULT_REGEXP2 = /\s+(\S{3,}|\w\S+ \S+|\w\S+ \S+ \S+|\w\S+ \S+ \S+ \S+)\s+(\S{3,}|\w+ \w+)\s+\S\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/
  RESULT_REGEXP3 = /\s+\S\s+(\S{3,}|\w\S+ \S+|\w\S+ \S+ \S+|\w\S+ \S+ \S+ \S+)\s+(\S{3,}|\w+ \w+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/
  YEAR = 0
  QUARTER = 1
  ST = 2
  SA = 3
  PM = 4
  TS = 5
  COURSE = 6
  TEACHER = 7
  PARTICIPANT = 8
  RESULT5 = 9
  RESULT4 = 10
  RESULT3 = 11
  RESULT2 = 12
  RESULT1 = 13
  RESULT0 = 14
  UP4 = 15
  
  ################################################################################
  # クラスインスタンス変数
  ################################################################################
  @last_modified = nil
  @pdf_urls = []
  @results = []
  
  class << self
    attr_reader :results
  end
  
  ################################################################################
  # 成績公開ページからpdfのurlを取得
  # @return [Array]
  ################################################################################
  def self.scrape_url
    OpenURI.open_uri(DISCLOSURE, 'rb') do |sio|
      unless @last_modified == sio.last_modified
        @last_modified = sio.last_modified
        @pdf_urls = []
        html = sio.read
        while html
          @pdf_urls << "https://aiit.ac.jp#{$1}" if PDF_REGEXP.match(html)
          html = $' # $'はマッチ以降のテキスト
        end
      end
    end
    @pdf_urls
  end
  
  ################################################################################
  # 成績を取得する正規表現に行がマッチしたら成績の配列に追加
  # @return [Boolean]
  ################################################################################
  def self.match_line(yq, reg_exp, line)
    match = reg_exp.match(line)
    if match
      array = match[1..-1].to_a
      # 2017年2Qの「組込みシステム特論」で科目名と指導教員が入れ替わってしまうため
      # 全角文字＋全角スペース＋全角文字のパターンを捜して入れ替え
      (array[0], array[1] = array[1], array[0]) if array[0] =~ /\S+　\S+/
      @results << yq + array
    end
    !!match
  end
  
  ################################################################################
  # pdfのurlから年度とクォータを取得
  # @return [void]
  ################################################################################
  def self.year_quarter(url)
    yq = File.basename(url).split('.').first.split('_')[0..1]
    
    if yq[0] =~ /^[hH]\d+$/
      yq[0] = (yq[0][1..-1].to_i + 1988).to_s
    elsif yq[0] =~ /^[rR]\d+$/
      yq[0] = (yq[0][1..-1].to_i + 2018).to_s
    else
      yq[0] = '不明'
    end
    
    if yq[1] =~ /^[1234][qQ]$/
      yq[1].upcase!
    else
      yq[1] = '不明'
    end
    
    yq + ['', '', '', '']
  end
  
  ################################################################################
  # pdfからテキストを抽出して正規表現とのマッチを行う。複数行に分かれている場合も対応
  # @return [Array]
  ################################################################################
  def self.scrape_result
    return @results unless @results.empty?
    
    @pdf_urls.each do |url|
      yq = year_quarter(url)
      last_line = ''
      OpenURI.open_uri(url) do |sio|
        reader = PDF::Reader.new(sio)
        reader.pages.first.text.split("\n").each do |line|
          if match_line(yq, RESULT_REGEXP, line)
            last_line = ''
            next
          end
          if last_line.empty?
            last_line = line
            next
          end
          found = false
          [RESULT_REGEXP, RESULT_REGEXP2, RESULT_REGEXP3].each do |reg_exp|
            if match_line(yq, reg_exp, last_line + line)
              last_line = ''
              found = true
              break
            end
          end
          last_line = line unless found
        end
      end
    end
    @results = COURSE2020 + @results
  end
  
  ################################################################################
  # 科目名が各年度の人材像別推奨科目に含まれているかチェック
  # @return [void]
  ################################################################################
  def self.set_recommended
    @results.each do |result|
      result[ST] = '◎' if STRATEGIST[result[YEAR]].include?(result[COURSE])
      result[SA] = '◎' if SYSTEM_ARCHITECT[result[YEAR]].include?(result[COURSE])
      result[PM] = '◎' if PROJECT_MANAGER[result[YEAR]].include?(result[COURSE])
      result[TS] = '◎' if TECHNICAL_SPECIALIST[result[YEAR]].include?(result[COURSE])
    end
  end
  
  ################################################################################
  # 評点4以上の割合
  # @return [void]
  ################################################################################
  def self.up4
    @results.each do |result|
      percent = ''
      unless result[PARTICIPANT].empty?
        up4 = result[RESULT5].to_i + result[RESULT4].to_i
        participant = result[PARTICIPANT].to_i - result[RESULT0].to_i
        percent = '%.01f' % (up4.to_f / participant.to_f * 100).round(1)
      end
      result << percent
    end
  end
  
  ################################################################################
  # クラス初期化時にスクレイピングを行う
  ################################################################################
  scrape_url
  scrape_result
  set_recommended
  up4
end

# Result.scrape_url
# require 'pp'
# result = Result.scrape_result
# result.each {|it| p it}
# p Result.results.size
