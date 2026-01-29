import cv2
import numpy as np

# 1. Read image
image = cv2.imread("image.jpg")   # change path if needed
gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

# 2. Smoothing
mean_filtered = cv2.blur(gray, (3, 3))
gaussian_filtered = cv2.GaussianBlur(gray, (3, 3), 0)

# 3. Sobel Edge Detection
sobel_x = cv2.Sobel(gray, cv2.CV_64F, 1, 0, ksize=3)
sobel_y = cv2.Sobel(gray, cv2.CV_64F, 0, 1, ksize=3)
sobel = cv2.magnitude(sobel_x, sobel_y)
sobel = cv2.convertScaleAbs(sobel)

# 4. Prewitt Edge Detection
prewitt_x = np.array([[-1,0,1],[-1,0,1],[-1,0,1]])
prewitt_y = np.array([[1,1,1],[0,0,0],[-1,-1,-1]])

prewitt_x_edge = cv2.filter2D(gray, -1, prewitt_x)
prewitt_y_edge = cv2.filter2D(gray, -1, prewitt_y)
prewitt = cv2.add(prewitt_x_edge, prewitt_y_edge)

# 5. Canny Edge Detection
canny = cv2.Canny(gray, 100, 200)

# 6. Display outputs
cv2.imshow("Original Image", gray)
cv2.imshow("Mean Filter", mean_filtered)
cv2.imshow("Gaussian Filter", gaussian_filtered)
cv2.imshow("Sobel Edge", sobel)
cv2.imshow("Prewitt Edge", prewitt)
cv2.imshow("Canny Edge", canny)

cv2.waitKey(0)
cv2.destroyAllWindows()
