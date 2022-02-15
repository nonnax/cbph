#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-02-05 19:46:19 +0800

def puts_md(node, img, alt='none')
  markup=<<~___
          [
            ![
            #{alt}
            ](#{img})
          ](https://chaturbate.com/#{alt})
  ___
  puts markup.gsub(/(\n|\s)+/, '').gsub(/\e\[\?(\d+)(\d+)l|\e\[\?(\d+)(\d+)h/, '')
end

ARGF.each_line do |f|
  node = File.basename(f)
  alt = File.basename(f, '.*')
  puts_md(node, f, alt) if f.match(/http/)
end
