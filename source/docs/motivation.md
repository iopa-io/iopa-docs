---
title: "Motivation"
description: "The problem that IOPA is trying to solve"
---
## Abstract

Communication between people, devices and things is become one of the greatest enablers and greatest levelers for societies today.

However, far too much time and energy is spent agreeing on standards and protocols for communicating, and each device, thing, or person needs to then learn and include these protocols in whatever components they use.

## Not a hardware layer

Some of the protocols are at a hardware level.  For example using Zigbee, Bluetooth or Z-Wave to communicate between nearby devices in a home automation setting.   Large standards bodies emerge that define and set the standards, taking into account the resource constraints of the day (be it energy usage, computational efficiency, resilience and latency characteristics, memory availability, cost, cognitive load of programmers, etc.), and since these are changing constantly it is not surprising that the protocols themselves tend to evolve.

## Not an information layer

Some of the protocols are at a data or information layer.  For example using XML, SOAP or JSON to communicate between "web services" running on one of the devices mentioned above.    Sometimes the hardware and information layers are tightly coupled, sometimes they are independent (e.g., HTTP can run on TCP or UDP, both can run on IP over Ethernet or Token Ring).

## Rather, a Pattern

Yet despite all this complexity and choice, the underlying functional needs are often the same.  Stores hold state.  Actions change state.  Stores notify everyone of the new state.    State can be the brightness level of a light bulb, or the synthesized health risk state of a human.    Architectures such as Elm, Flux, Redux, etc. all aim to keep things simple with a well defined flow of state changes.   Publish/Subscribe and Eventing based architectures achieve similar unifying results.   

The Internet of Protocols Association does not wish to enter the protocol fray nor create yet another new standard for machine to machine communication.  Rather, it wants to **abstract** the protocols in such a way so that commonly used functional needs are met regardless of the underlying protocol.

## Guiding principles

There are few goals with this effort:
* It is much more about a specification of **how** to do things than specific implementations
* It is programming language agnostic, but with clear reference implementations in three widely used languages with similar C-lang heritage (JavaScript, Swift and C#).   
* It works with functional programming techniques, but also works with sequential programming 
* Implementations can interoperate without relying on core or shared libraries -- everything is represented using the most basic "property bags" of whatever the underlying programming language
* Implementations are modular and can be decomposed into hundreds or thousands of microservices easily, but aggregated into large stacks or processing pipelines whenever needed 
* The focus is purely on machine, device, human, thing, animal communication across local, regional, global and interstellar networks.   Adaptions to solve machine learning, functional pipe programming, etc. are interesting but delegated outside of the IOPA namespace (for example, a usage to run software on web, desktop, mobile platforms natively without change is enabled by a complementary effort called NODEKIT that quietly uses IOPA at the core). 
* The focus is on state, stores and transfer of state between stores, listeners and action creators.
* It is working in production today