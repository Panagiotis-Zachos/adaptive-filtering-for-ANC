# Adaptive Filtering for Active Noise Control
Simulations for Active Noise Control with adaptive filters for Over-Ear Headphones.

This is a project for the class "Digital Sound Technology". 

The HpCF for the AKG K141 MKII headphones was provided by the [ASH-IR Dataset](https://github.com/ShanonPearce/ASH-IR-Dataset/tree/master/HpCFs). 

The 'cocktail party' noise effect is provided by [Soundboard](https://www.soundboard.com/sb/sound/1026980).

The 'Street Noise' effect is from the following YouTube [video](https://www.youtube.com/watch?v=jg9OTyOI6rY).

The song used for the tests was "Shadow Play" by Rory Gallagher. Due to copyright law the song has not been uploaded in this repository.

In this project, two different ANC methods are studied.

The first assumes knowledge of the environmental noise i.e. through a microphone placed outside the headphone enclosure. The headphone enclosure is assumed to not be known and is simulated as shown in the Image below, where x(n) is the sound reproduced by the device (e.g. cellphone) and η(n) is the environmental noise.

![alt text](https://github.com/Panagiotis-Zachos/adaptive-filtering-for-ANC/blob/main/images/Adaptive_model_with_knowledge.JPG?raw=true)

In the second case, it is assumed that information about the environmental noise is not available. The de-noising is performed through adaptive filtering using only knowledge of the reproduced signal x(n). The respective block diagram is shown below.

![alt text](https://github.com/Panagiotis-Zachos/adaptive-filtering-for-ANC/blob/main/images/adaptive_model.JPG?raw=true)
