<div id="top"></div>
<!--
*** Used a trimmed-down version of the markdown template here: https://github.com/othneildrew/Best-README-Template/blob/master/BLANK_README.md
-->

<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<!-- PROJECT LOGO -->
<br />
<div align="left">

<h3 align="left">UKBB Phenotype Dashboard</h3>

  <p align="left">
    A web-based application interface for UK Biobank phenotype exploration
    <br />
    <a href="https://github.com/mryals/ukb_phenotype_dashboard"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/mryals/ukb_phenotype_dashboard">View Demo</a>
    ·
    <a href="https://github.com/mryals/ukb_phenotype_dashboard/issues">Report Bug</a>
    ·
    <a href="https://github.com/mryals/ukb_phenotype_dashboard/issues">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

The UKBB phenotype dashboard was designed as an accessible interface to the UKBB phenotype data.  The goal is to provide an example application that would be useful to a broad audience of UKBB users.  Phenotype data and ICD10 primary care mapping can be searched using this application, and phenotypes can be exported into an analysis-ready file for GWAS, pheWAS, and other analyses.

<p align="right">(<a href="#top">back to top</a>)</p>



### Built With

* [RShiny](https://shiny.rstudio.com/)
* [SQLite](https://www.sqlite.org/)
* [UKBB](https://www.ukbiobank.ac.uk/)

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

Note: This repository is not an R package.  To get started using your own local phenotype dashboard, you can download the codes here and make some minor modifications to point to the relevant local input files to run, and then you can explore the dashboard functions.

### Prerequisites

You will be required to have access to the raw UKBB data files.  You will also be required to have some of the mapping files available on the UKBB data showcase downloaded into your workspace.

### Installation

1. Follow the raw UKBB md5sum check, decryption, and data unpacking steps using `ukbmd5`,`ukbunpack`, and `ukbconv` available [here](https://biobank.ndph.ox.ac.uk/showcase/download.cgi)
2. Convert the file to long-format using `ukb_to_long.R`
3. Set up an SQLite database in SQLite3 using `ukb.sql`
   ```sh
   sqlite3 database_name.db < ukb.sql
   ```
4. Set up a Shiny dashboard folder to hold the codes `data_prep.R`, `global.R`, `ui.R`, and `server.R` codes along with a `www` subfolder structure to hold your downloaded files and your database file.
5. In RStudio (recommended), run the dashboard by clicking `Run App` in the top corner of the Source panel.  Or run directly by using `shiny::runApp`

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- USAGE EXAMPLES -->
## Usage

A few basic usage examples of the dashboard are available to look at in our ASHG 2021 poster.  Take a look at our abstract and poster [here](https://eventpilotadmin.com/web/page.php?page=Session&project=ASHG21&id=P2406).

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- CONTRIBUTING -->
## Contributing

Please feel free to reach out to our team with any thoughts, contributions, issues, or changes you might be interested in with regards to this project.  We have a number of ideas for additional features to add to the dashboard, so also feel free to check back again and see if we have added some utility you may be interested in.

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- CONTACT -->
## Contact and acknowledgements

UKBB phenotype formatting code, Shiny dashboard code author: Liping Hou - [https://www.pharmalex.com/contact-us](https://www.pharmalex.com/contact-us)
Abstract, poster, and github repo author: Matthew Ryals - [https://www.pharmalex.com/contact-us](https://www.pharmalex.com/contact-us)

Project Link: [https://github.com/mryals/ukb_phenotype_dashboard](https://github.com/mryals/ukb_phenotype_dashboard)

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[license-shield]: https://img.shields.io/github/license/mryals/ukb_phenotype_dashboard.svg?style=for-the-badge
[license-url]: https://github.com/mryals/ukb_phenotype_dashboard/blob/master/LICENSE
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/linkedin_username
