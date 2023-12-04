#! /usr/bin/env bqn
data←•FLines "input.txt"

data↩{𝕩∾"."}¨data
hl←≠∾1↑data
vl←≠data

parts←>{(11)=𝕩}{".0123456789"⊐𝕩}¨data
parts {(𝕩+(hl⥊0)»𝕩)+(hl⥊0)«𝕩}↩
parts {(𝕩+⍉(vl⥊0)»⍉𝕩)+⍉(vl⥊0)«⍉𝕩}↩
parts {⥊ ⋈˘0<¨𝕩}↩

ns←∾´{10≠𝕩}{"0123456789"⊐𝕩}¨data
ns {𝕩×1++`1⌊(»⊸+)¬𝕩}↩
numbers←1↓ns⊔∾´data
idx←¯1+(+`⊸×)0<¨≠¨numbers

numbers {(10⊸×⊸+˜´∘⌽-⟜'0')¨⥊∾idx⊔𝕩}↩
isPart←1↓ns⊔∾´parts
result←+´numbers×1⌊(+´)¨⥊∾idx⊔isPart
•Show result