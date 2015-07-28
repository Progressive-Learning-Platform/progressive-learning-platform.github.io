---
title: Glossary
layout: main-noanc
---


<div class="medium-12 columns" markdown="1" >

<div id="stuff"></div>

#### A ####
{:.ancs}

#### B ####
{:.ancs}

* ##### Button Interrupt
    * [overview]({{site.baseurl}}/plptool.html#button-interrupt)
* ##### Breakpoints
    * [overview]({{site.baseurl}}/plptool.html#breakpoints)

#### C ####
{:.ancs}

#### D ####
{:.ancs}

#### E ####
{:.ancs}

#### F ####
{:.ancs}

#### G ####
{:.ancs}

* ##### GPIO
    * [overview]({{site.baseurl}}/plptool.html#gpio-general-purpose-inputoutput)
    * [hardware]({{site.baseurl}}/hardware.html#gpio)

#### H ####
{:.ancs}


#### I ####
{:.ancs}

#### J ####
{:.ancs}

#### K ### 
{:.ancs}

#### L ####
{:.ancs}

* ##### LEDs 

    * [overview]({{site.baseurl}}/plptool.html#leds)
    * [hardware]({{site.baseurl}}/hardware.html#leds)

#### M ####
{:.ancs}

#### N ####
{:.ancs}


#### O ####
{:.ancs}

#### P ####
{:.ancs}

* ##### PLP Tool
    * [getting]({{site.baseurl}}/plptool.html#getting-plptool)
    * [running]({{site.baseurl}}/plptool.html#running-plptool)
        * [command line]({{site.baseurl}}/plptool.html#launching-plptool-with-the-command-line)
    * [GUI]({{site.baseurl}}/plptool.html#plptool-graphical-user-interface-gui)
    * [simulator]({{site.baseurl}}/plptool.html#simulator)


#### Q ####
{:.ancs}

#### R ####
{:.ancs}

#### S ####
{:.ancs}

* ##### Seven Segment Display
    * [overview]({{site.baseurl}}/plptool.html#seven-segment-displays)
    * [hardware]({{site.baseurl}}/hardware.html#seven-segment-displays)

* ##### Switches
    * [overview]({{site.baseurl}}/plptool.html#switches)
    * [hardware]({{site.baseurl}}/hardware.html#switches)

#### T ####
{:.ancs}

#### U ####
{:.ancs}

* ##### UART
    * [overview]({{site.baseurl}}/plptool.html#uart)
    * [hardware]({{site.baseurl}}/hardware.html#uart)


#### V ####
{:.ancs}

* ##### VGA
    * [overview]({{site.baseurl}}/plptool.html#vga)
    * [hardware]({{site.baseurl}}/hardware.html#vga)

#### W ####
{:.ancs}

#### X ####
{:.ancs}

#### Y ####
{:.ancs}

#### Z ####
{:.ancs}



</div>

<script src="{{site.baseurl}}/js/vendor/jquery.js"></script>
<script type="text/javascript">
{% for page in site.pages %}
    console.log("{{page.title}}");
    console.log("{{page.url}}");
    $("#stuff").append("<p>{{page.title}} {{page.url}}</p>");
{% endfor %}
</script>
