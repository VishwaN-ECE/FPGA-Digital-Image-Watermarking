import cv2
import numpy as np
image = cv2.imread("image.jpg")  
gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
_, globalThresh = cv2.threshold(gray, 127, 255, cv2.THRESH_BINARY)
adaptiveThresh = cv2.adaptiveThreshold(gray,255,cv2.ADAPTIVE_THRESH_MEAN_C,cv2.THRESH_BINARY,11,2)
_, otsuThresh = cv2.threshold(gray,0,255,cv2.THRESH_BINARY + cv2.THRESH_OTSU)

cv2.imshow("Original Image", gray)
cv2.imshow("Global Thresholding", globalThresh)
cv2.imshow("Adaptive Thresholding", adaptiveThresh)
cv2.imshow("Otsu Thresholding", otsuThresh)

cv2.waitKey(0)
cv2.destroyAllWindows()
