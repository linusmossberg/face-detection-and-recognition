# Face Detection and Recognition
Face Detection and Recognition program developed in Matlab for the course *TNM034 - Advanced Image Processing* at Linköpings Universitet. Both Eigenfaces and Fisherfaces recognition models are implemented. The program uses the *"Caltech 1999 Faces"*-dataset which contains 450 images of 27 people with various facial expressions, taken in different environments and under various lighting conditions.

The models are trained with 72 images of 16 people that have been assigned different ID-numbers. The remaining people are unknown and the program should recognize them as such and return an ID of 0. 

## Accuracy
Of the remaining 378 images, the program is able to correctly detect and recognize 98.67% of the faces using the fisherfaces model, either with the ID corresponding to the person or 0 if the person is unknown. This could be increased to about 99.2% with more training images, but no more since the detection fails in three extremely underexposed images. The eigenfaces model only correctly recognizes 91.01% of the faces, despite using 4.5x more principal components than the fisherfaces model.

The training images are not included in these numbers as these are guaranteed to be recognized correctly. Both of these have distance thresholds set to optimally reduce the sum of false positives and negatives.

| Model       | Accuracy |
| ----------- | -------- |
| Fisherfaces | 98.67%   |
| Eigenfaces  | 91.01%   |

## Requirements
The following products are required to run the program:

| Name                                    | Version      |
| --------------------------------------- | ------------ |
| Matlab                                  | R2019b (9.7) |
| Image Processing Toolbox                | 11.0         |
| Statistics and Machine Learning Toolbox | 11.6         |
