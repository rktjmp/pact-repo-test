;; generates a repository with some commits

(local {:format fmt} string)

; (macro git [...]
;   (let [s (-> (accumulate [s [:git] _ p (ipairs [...])]
;                 (doto s (table.insert (tostring p))))
;               (table.concat " "))]
;     `(os.execute ,s)))

(macro init [...]
  `(do
     (var ,(sym :BRANCH) [:main])
     (var ,(sym :COMMIT) 0)
     (var ,(sym :MAJOR) 0)
     (var ,(sym :MINOR) 0)
     (var ,(sym :PATCH) 0)
     ["git init ."
      "git branch -m main"
      "git add generate-repo.fnl force.sh clean.sh"
      "git commit -m 'tooling'"
      ,...]))

(macro +major []
  `(do
     (set ,(sym :MAJOR) (+ 1 ,(sym :MAJOR)))
     (set ,(sym :MINOR) 0)
     (set ,(sym :PATCH) 0)
     (fmt "git tag -a -m 'major bump' v%s.%s.%s"
          ,(sym :MAJOR)
          ,(sym :MINOR)
          ,(sym :PATCH))))

(macro +minor []
  `(do
     (set ,(sym :MINOR) (+ 1 ,(sym :MINOR)))
     (set ,(sym :PATCH) 0)
     (fmt "git tag -a -m 'minor bump' v%s.%s.%s"
          ,(sym :MAJOR)
          ,(sym :MINOR)
          ,(sym :PATCH))))

(macro +patch []
  `(do
     (set ,(sym :PATCH) (+ 1 ,(sym :PATCH)))
     (fmt "git tag v%s.%s.%s"
          ,(sym :MAJOR)
          ,(sym :MINOR)
          ,(sym :PATCH))))

(macro commit []
  `(do
     (set ,(sym :COMMIT) (+ 1 ,(sym :COMMIT)))
     [(fmt "touch %s.txt" ,(sym :COMMIT))
      (fmt "git add %s.txt" ,(sym :COMMIT))
      (fmt "git commit -m 'added %s.txt'" ,(sym :COMMIT))]))

(macro tag [name ?annotate]
  (if ?annotate
    `(fmt "git tag -a -m '%s' %s" ,?annotate ,name)
    `(fmt "git tag %s" ,name)))

(macro create-branch [name]
  `(fmt "git branch -c %s" ,name))

(macro switch [name ...]
  `(do
     (table.insert ,(sym :BRANCH) 1 ,name)
     [(fmt "git switch %s" ,name)
      [,...] ;; sub table so we don't truncate it
      (do
        (table.remove ,(sym :BRANCH) 1)
        (fmt "git switch %s" (. ,(sym :BRANCH) 1)))]))

(macro merge [name]
  `(fmt "git merge %s" ,name))

(fn exec [list dry?]
  (each [_ l (ipairs list)]
    (match (type l)
      :string (do
                (print "exec" l)
                (if (not dry?)
                  (match (os.execute l)
                    (true _) nil
                    (nil n) (error (fmt "%s failed %s" l n)))))
      :table (exec l dry?))))

(local commands
  (init
    (fcollect [i 0 14]
      [(commit)
       (match i
         (where _ (= 0 (% i 3)))
         (+patch)
         (where _ (= 0 (% i 5)))
         (+minor)
         (where _ (= 0 (% i 8)))
         (+major))])
    (commit)
    (commit)
    (+minor)
    (create-branch :dev)
    (switch :dev
            (commit)
            (commit)
            (commit)
            (tag "some-tag" "and an annotation"))
    (create-branch :feat-one)
    (switch :feat-one
      (commit)
      (commit)
      (tag "test-here")
      (tag "test-here-dup")
      (commit))
    (merge :feat-one)
    (create-branch :feat-two)
    (switch :feat-two
      (commit)
      (commit))
    (fcollect [i 0 1000]
      [(commit)
       (match i
         (where _ (= 0 (% i 100)))
         (+major)
         (where _ (= 0 (% i 30)))
         (+minor)
         (where _ (= 0 (% i 3)))
         (+patch)
         )])))

(exec commands)


; (local {: view} (require :fennel))
; (print (view commands))

  ; (switch :dev
  ;   (commit)
  ;   (commit)
  ;   (tag :dev-test "with annotation")
  ;   (commit))
  ; (switch :feat
  ;   (commit)
  ;   (commit)
  ;   (tag :feat-sample)
  ;   (commit)
  ;   (commit))
  ; (merge :feat)
  ; (tag "v0.0.2")
  ; (commit)
  ; (commit))


