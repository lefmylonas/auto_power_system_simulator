# Auto Design Framework for Real-time Power System Simulators

A prototype implementation of an automatic design framework for real-time power system simulators, in the context of a diploma thesis. 

The design is divided into two parts: the **user-oriented section**, written in Matlab R2017a, and the **hardware-oriented section**, written in VHDL.

The purpose of the project is to automate and simplify the design of customized hardware architectures for power system simulation, without concerning the user of the platform. Currently, it supports power networks comprising passive elements (whatever can be modeled as a combination of resistors, inductors and capacitors) and transformers. Support of voltage sources in the network simulation of the user-oriented section is included, however it hasn't been added to hardware-oriented section yet. Current sources are fully compatible, though.
