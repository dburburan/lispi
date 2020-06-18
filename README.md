# Lispi

This is an implementation of the Lispi syntax for Racket.

Lispi introduces colon lists, which are automatically closed based on indentation. This greatly reduces the many trailing parentheses often found at the end of Lisp functions.

### Installation

todo - how to install github hosted package with raco

### Usage Examples

```
#lang lispi racket

writeln: "hello world"
```
```
define: factorial: n              =>   (define (factorial n)
  match: n                               (match n
    0: 1                                   (0 1)
    _: *: n (factorial +: n -1)            (_ (* n (factorial (+ n -1))))))

factorial: 5                           (factorial 5)
```
fn: (1 2 3 4)
```
define: fibonacci: n              =>   (define (fibonacci n)
  let: fib :|                            (let fib (
      i: 0                                   (i 0)
      u: 1                                   (u 1)
      v: 1                                   (v 1))
    if: (>= i +: n -2)                     (if (>= i (+ n -2))
      v                                      v
      fib: (+ i 1) v (+ u v)                 (fib (+ i 1) v (+ u v)))))

for: (i: in-range: 10)                 (for ((i (in-range 10)))
  printf: "~a " fibonacci: i             (printf "~a " (fibonacci i))
printf: "\n"                           (printf "\n")
```

## Syntax

Lispi introduces two new tokens - colon ":" and pipe "|", which correspond to open and close parens. They can literally be used as such:

`:writeln "hello"|` means => `(writeln "hello")`

This isn't how they'd typically be used but it shows how closely they mirror the existing open and close parens. There are also the following modifiers to the colon (detailed later):

- `:|` which is closed by `|`
- `:(` which is closed by `)`
- `:[` which is closed by `]`
- `:{` which is closed by `}`

### Colon Lists `:`

A colon begins a list *before* the previous token on the same line. This mirrors the importance of the first token in lists representing function calls - the token before the colon is the function name, and the rest are the arguments. The only exception is at the start of a line, where there isn't a previous token, and so the list simply opens at the colon's location.
  ```
  aaa: bbb ccc ddd...    =>   (aaa bbb ccc ddd...
  ```
  ```
  aaa bbb: ccc ddd...    =>   aaa (bbb ccc ddd...
  ```
  ```
  :aaa bbb ccc ddd...    =>   (aaa bbb ccc ddd...
  ```
- Differing whitespace on the same line has no effect
  ```
  aaa : bbb ccc ddd...   =>   (aaa bbb ccc ddd...
  ```
  ```
  aaa :bbb ccc ddd...    =>   (aaa bbb ccc ddd...
  ```
  ```
  aaa bbb :ccc ddd...    =>   aaa (bbb ccc ddd...
  ```
- Line breaks do have an effect though. A colon won't go searching the previous line for a token
  ```
  aaa     =>   aaa
  : bbb        (bbb)
  ```

Most of the time, colon lists don't need to be explicitly closed with `|`. When a colon is encountered, indentation processing begins, and the colon list is automatically closed upon encountering one of the following:

- end of file
  ```
  :aaa     =>   (aaa)
  ```
- a line with indent <= the initial line's indent
  ```
  :aaa     =>   (aaa)
  bbb           bbb
  ```
  ```
  :aaa     =>   (aaa
    bbb           bbb)
  ccc           ccc
  ```
  ```
  :aaa     =>   (aaa
    :bbb          (bbb))
  :ccc          (ccc)
  ```
- a line with indent < the previous line's indent (for partial dedent, see later section)
  ```
  :aaa     =>   (aaa
      bbb           bbb)
    ccc           ccc
  ```
- an explicit close parenthesis
  ```
  (:aaa)   =>   ((aaa))
  ```

---

After the initial colon, all further colons on the same line close at the end of that line, regardless of the next line's indent- only the first colon is aware of indentation. For more indentation-aware colons on the same line, see `:|`

```
aaa: bbb:   =>   (aaa (bbb)
  ccc              ccc)
```
```
aaa: bbb: ccc: ddd   =>   (aaa (bbb (ccc ddd))
  eee: fff                  (eee fff))
```

### Interaction with parentheses `(` `[` `{` `}` `]` `)`

Normal parens lists can be both nested inside colon lists, and have colon lists nested inside.

- The token preceding a colon can be a list, not just a single token
  ```
  (aaa bbb): ccc ddd   => ((aaa bbb) ccc ddd)
  ```
  - It can also be a colon list, but this requires an explicit close `|`
    ```
    aaa: bbb ccc|: ddd eee   =>   ((aaa bbb ccc) ddd eee)
    ```
  - Or, alternatively
    ```
    aaa:: bbb ccc| ddd eee   =>   ((aaa bbb ccc) ddd eee)
- All colon lists are closed upon encountering a close parens
  ```
  (aaa: bbb: ccc:) ddd eee   =>   ((aaa (bbb (ccc)))) ddd eee
  ```

### Passing of indentation information

- Indentation information doesn't recursively flow into lists. As a result starting a colon list inside a parens list, on the same line, will always end on that line.
  ```
  (aaa bbb:   =>   (aaa (bbb)
    ccc)             ccc)      ; ccc is not an argument to function bbb
  ```
  - After a line break a colon will then be aware of the current indent
  ```
  (aaa        =>   (aaa
    bbb:             (bbb
      ccc)             ccc))   ; ccc is an argument to function bbb
  - This is the same reason only the first colon list is able to continue onto the next line.

### Credits

Special thanks to Michael for suggesting a couple of visual improvements

