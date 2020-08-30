
<!--#echo json="package.json" key="name" underline="=" -->
nodemcu-firmware-wifigpio-pmb
=============================
<!--/#echo -->

<!--#echo json="package.json" key="description" -->
A NodeMCU firmware image for GPIO via WiFi.
<!--/#echo -->


Just a demo of how to use [nodemcu-build-as-github-action][nodemcu-baga].



Usage
-----

See [the tutorial repo][wifigpio-tutorial].


<!--#toc stop="scan" -->
&nbsp;


  [nodemcu-baga]: https://github.com/mk-pmb/nodemcu-build-as-github-action/
  [wifigpio-tutorial]: https://github.com/mk-pmb/nodemcu-wifigpio-tutorial-pmb/


License
-------

<!--#echo json="package.json" key=".license" -->
MIT
<!--/#echo -->

Disclaimers and third party content information:

* The configuration files included in this repo, and/or included in
  software packages generated using this repo, contain MIT-licensed
  code from the original NodeMCU firmware repo at
  https://github.com/nodemcu/nodemcu-firmware .
  For a full list of contributors, see the project history there.

* I'm not sure whether I can effectively grant (sub)licenses for any use
  of the files that this repo's GitHub Action runs create.
  My layman's interpretation (I'm not a lawyer) is that you should clone
  this repo, run the Github Action yourself, thereby creating a version that
  you yourself made (because the GHA was a tool under your control)
  and this way hopefully you can use the license of the firmware source.
