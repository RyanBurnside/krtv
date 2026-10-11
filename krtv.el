;;; krtv.el --- View live KRTV image feed -*- lexical-binding: t; -*-

;; Copyright Ryan Burnside 2026

;; Author: Ryan Burnside
;; Version: 0.1.0
;; Package-Requires: ((emacs "26.1"))
;; Keywords: multimedia, news

;;; Commentary:

;; Provides an interactive command `krtv-get-feed` to fetch and display
;; the latest live image feed from KRTV inside a dedicated Emacs buffer.

;;; Code:

(defun krtv--url-handler (status img-buf)
  (unwind-protect
      (if (plist-get status :error)
          (message "Failed to download KRTV image.")
        ;; We are inside the temporary download buffer here
        (goto-char (point-min))
        ;; Search for headers/body separator (handling both Unix and Windows line endings)
        (re-search-forward "\r?\n\r?\n" nil t)
        (let ((image-data (buffer-substring (point) (point-max))))
          (with-current-buffer img-buf
            (let ((inhibit-read-only t))
              (erase-buffer)
              (insert-image (create-image image-data 'jpeg t))
              (goto-char (point-min))))
          (unless (get-buffer-window img-buf)
            (display-buffer img-buf))))
    ;; Ensure the temporary url-retrieve buffer is always killed when done
    (kill-buffer)))

(defun krtv--refresh-image ()
  "Fetch the latest KRTV image and update the display buffer."
  (let ((url "https://mediaassets.krtv.com/KRTV/KRTV.jpg")
        (buf (get-buffer-create "*KRTV Image Timer*")))
    (url-retrieve url
                  (lambda (status)
                    (krtv--url-handler status buf)))))

;;;###autoload
(defun krtv-get-feed ()
  (interactive)
  (krtv--refresh-image))

(provide 'krtv)
;;; krtv.el ends here
