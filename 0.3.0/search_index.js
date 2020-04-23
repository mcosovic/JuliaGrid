var documenterSearchIndex = {"docs":
[{"location":"man/flow/#Power-Flow-1","page":"Power Flow","title":"Power Flow","text":"","category":"section"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"The function runs the AC and DC power flow analysis, where reactive power constraints can be used for the AC power flow analysis.","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"The AC power flow analysis includes four different algorithms:","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"Newton-Raphson,\nGauss-Seidel,\nXB fast decoupled Newton-Raphson,\nBX fast decoupled Newton-Raphson.","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"","category":"page"},{"location":"man/flow/#Run-Settings-1","page":"Power Flow","title":"Run Settings","text":"","category":"section"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"The power flow settings should be given as input arguments of the function runpf(...). Although the syntax is given in a certain order, for methodological reasons, only DATA must appear, and the order of other inputs is arbitrary, as well as their appearance.","category":"page"},{"location":"man/flow/#Syntax-1","page":"Power Flow","title":"Syntax","text":"","category":"section"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"runpf(DATA, METHOD)\nrunpf(DATA, METHOD, DISPLAY)\nrunpf(DATA, METHOD, DISPLAY; ACCONTROL)\nrunpf(DATA, METHOD, DISPLAY; ACCONTROL, SOLVE)\nrunpf(DATA, METHOD, DISPLAY; ACCONTROL, SOLVE, SAVE)","category":"page"},{"location":"man/flow/#Description-1","page":"Power Flow","title":"Description","text":"","category":"section"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"runpf(DATA, METHOD) computes power flow problem\nrunpf(DATA, METHOD, DISPLAY) shows results in the terminal\nrunpf(DATA, METHOD, DISPLAY; ACCONTROL) sets variables for the AC power flow\nrunpf(DATA, METHOD, DISPLAY; ACCONTROL, SOLVE) sets the linear system solver\nrunpf(DATA, METHOD, DISPLAY; ACCONTROL, SOLVE, SAVE) exports results","category":"page"},{"location":"man/flow/#Output-1","page":"Power Flow","title":"Output","text":"","category":"section"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"results = runpf(...) returns results of the power flow analysis","category":"page"},{"location":"man/flow/#Examples-1","page":"Power Flow","title":"Examples","text":"","category":"section"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"julia> results = runpf(\"case14.h5\", \"nr\", \"main\", \"flow\", \"generator\")","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"julia> results = runpf(\"case14.xlsx\", \"nr\", \"main\"; max = 10, stop = 1.0e-8)","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"julia> results = runpf(\"case14.h5\", \"gs\", \"main\"; max = 500, stop = 1.0e-8, reactive = 1)","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"julia> results = runpf(\"case14.h5\", \"dc\"; solve = \"lu\", save = \"D:/case14results.xlsx\")","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"","category":"page"},{"location":"man/flow/#Input-Arguments-1","page":"Power Flow","title":"Input Arguments","text":"","category":"section"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"The power flow function runpf(...) receives a group of variable number of arguments: DATA, METHOD, DISPLAY, and group of arguments by keyword: ACCONTROL, SOLVE, SAVE.","category":"page"},{"location":"man/flow/#Variable-Arguments-1","page":"Power Flow","title":"Variable Arguments","text":"","category":"section"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"DATA","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"Example Description\n\"case14.h5\" loads the power system data from the package\n\"case14.xlsx\" loads the power system data from the package\n\"C:/case14.xlsx\" loads the power system data from a custom path","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"METHOD","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"Command Description\n\"nr\" runs the AC power flow analysis using Newton-Raphson algorithm, default setting\n\"gs\" runs the AC power flow analysis using Gauss-Seidel algorithm\n\"fnrxb\" runs the AC power flow analysis using XB fast Newton-Raphson algorithm\n\"fnrbx\" runs the AC power flow analysis using BX fast Newton-Raphson algorithm\n\"dc\" runs the DC power flow analysis","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"DISPLAY","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"Command Description\n\"main\" shows main bus data display\n\"flow\" shows power flow data display\n\"generator\" shows generator data display","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"","category":"page"},{"location":"man/flow/#Keyword-Arguments-1","page":"Power Flow","title":"Keyword Arguments","text":"","category":"section"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"ACCONTROL","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"Command Description\nmax = value specifies the maximum number of iterations for the AC power flow, default setting: 100\nstop = value specifies the stopping criteria for the AC power flow, default setting: 1.0e-8\nreactive = 1 forces reactive power constraints, default setting: 0","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"SOLVE","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"Command Description\nsolve = \"mldivide\" mldivide linear system solver, default setting\nsolve = \"lu\" LU linear system solver","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"SAVE","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"Command Description\nsave = \"path/name.h5\" saves results in the h5-file\nsave = \"path/name.xlsx\" saves results in the xlsx-file","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"","category":"page"},{"location":"man/flow/#Input-Data-Structure-1","page":"Power Flow","title":"Input Data Structure","text":"","category":"section"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"The function works with input .h5 or .xlsx file extensions, with variables bus, generator, branch, and basePower, and uses the same data format as Matpower, except the first column in the branch data.","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"The minimum amount of information within an instance of the data structure required to run the module requires a bus and branch data.","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"First, the system base power is defined in (MVA) using basePower, and in the following, we describe the structure of other variables involved in the input file.","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"The bus data structure","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"Column Description Type Unit\n1 bus number positive integer \n2 bus type pq(1), pv(2), slack(3) \n3 demand active power MW\n4 demand reactive power MVAr\n5 shunt conductance active power MW\n6 shunt susceptance reactive power MVAr\n7 area positive integer \n8 initial voltage magnitude per-unit\n9 initial voltage angle deg\n10 base voltage magnitude kV\n11 loss zone positive integer \n12 minimum voltage magnitude per-unit\n13 maximum voltage magnitude per-unit","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"The generator data structure","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"Column Description Type Unit\n1 bus number positive integer \n2 generation active power MW\n3 generation reactive power MVAr\n4 maximum generation reactive power MVAr\n5 minimum generation reactive power MVAr\n6 voltage magnitude per-unit\n7 base power MVA\n8 status positive integer \n9 maximum generation active power MW\n10 minimum generation active power MW\n11 lower of pq curve active power MW\n12 upper of pq curve active power MW\n13 minimum at pc1 reactive power MVAr\n14 maximum at pc1 reactive power MVAr\n15 minimum at pc2 reactive power MVAr\n16 maximum at pc2 reactive power MVAr\n17 ramp rate acg active power per minut MW/min\n18 ramp rate 10 active power MW\n19 ramp rate 30 active power MW\n20 ramp rate Q reactive power per minut MVAr/min\n21 area factor positive integer ","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"The branch data structure","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"Column Description Type Unit\n1 branch number positive integer \n2 from bus number positive integer \n3 to bus number positive integer \n4 series parameter resistance per-unit\n5 series parameter reactance per-unit\n6 charging parameter susceptance per-unit\n7 long term rate power MVA\n8 short term rate power MVA\n9 emergency rate power MVA\n10 transformer turns ratio \n11 transformer shift angle deg\n12 status positive integer \n13 minimum voltage difference angle deg\n14 maximum voltage difference angle deg","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"","category":"page"},{"location":"man/flow/#Use-Cases-1","page":"Power Flow","title":"Use Cases","text":"","category":"section"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"The predefined cases are located in src/data as .h5 or .xlsx files.","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"Case Grid Bus Shunt Generator Branche\ncase3 transmission 3 0 1 3\ncase5 transmission 5 0 5 6\ncase5nptel transmission 5 0 1 7\ncase6 transmission 6 0 2 7\ncase6wood transmission 6 0 3 11\ncase9 transmission 9 0 3 9\ncase14 transmission 14 1 5 20\ncase_ieee30 transmission 30 2 6 41\ncase30 transmission 30 2 15 45\ncase47 distribution 47 4 5 46\ncase84 distribution 84 0 0 96\ncase118 transmission 118 14 54 186\ncase300 transmission 300 29 69 411\ncase1354pegase transmission 1354 1082 260 1991\ncase_ACTIVSg2000 transmission 2000 149 544 3206\ncase_ACTIVSg10k transmission 10000 281 2485 12706\ncase_ACTIVSg70k transmission 70000 3477 10390 88207","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"","category":"page"},{"location":"man/flow/#Output-Data-Structure-1","page":"Power Flow","title":"Output Data Structure","text":"","category":"section"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"The power flow function runpf(...) returns a single dictionary variable with keys bus, generator, branch, and with the additional key iterations if the AC power flow is executed.","category":"page"},{"location":"man/flow/#DC-Power-Flow-1","page":"Power Flow","title":"DC Power Flow","text":"","category":"section"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"The bus data structure","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"Column Description Type Unit\n1 bus number positive integer \n2 voltage angle deg\n3 injection active power MW\n4 generation active power MW\n5 demand active power MW\n6 shunt conductance active power MW","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"The generator data structure","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"Column Description Type Unit\n1 bus number positive integer \n2 generation active power MW","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"The branch data structure","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"Column Description Type Unit\n1 branch number positive integer \n2 from bus number positive integer \n3 to bus number positive integer \n4 from bus flow active power MW\n5 to bus flow active power MW","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"","category":"page"},{"location":"man/flow/#AC-Power-Flow-1","page":"Power Flow","title":"AC Power Flow","text":"","category":"section"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"The bus data structure","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"Column Description Type Unit\n1 bus number positive integer \n2 voltage magnitude per-unit\n3 voltage angle deg\n4 injection active power MW\n5 injection reactive power MVAr\n6 generation active power MW\n7 generation reactive power MVAr\n8 demand active power MW\n9 demand reactive power MVAr\n10 shunt conductance active power MW\n11 shunt susceptance reactive power MVAr","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"The generator data structure","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"Column Description Type Unit\n1 bus number positive integer \n2 generation active power MW\n3 generation reactive power MVAr","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"The branch data structure","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"Column Description Type Unit\n1 branch number positive integer \n2 from bus number positive integer \n3 to bus number positive integer \n4 from bus flow active power MW\n5 from bus flow reactive power MVAr\n6 to bus flow active power MW\n7 to bus flow reactive power MVAr\n8 branch injection reactive power MVAr\n9 loss active power MW\n10 loss reactive power MVAr\n11 from bus current magnitude per-unit\n12 from bus current angle deg\n13 to bus current magnitude per-unit\n14 to bus current angle deg","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"","category":"page"},{"location":"man/flow/#Flowchart-1","page":"Power Flow","title":"Flowchart","text":"","category":"section"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"The power flow flowchart depicts the algorithm process according to user settings.","category":"page"},{"location":"man/flow/#","page":"Power Flow","title":"Power Flow","text":"(Image: )","category":"page"},{"location":"man/generator/#Measurement-Generator-1","page":"Measurement Generator","title":"Measurement Generator","text":"","category":"section"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"The function uses the AC power flow analysis or predefined user data to generate measurements. The standalone measurement generator produces measurement data in a form suitable for the state estimation function.","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"","category":"page"},{"location":"man/generator/#Run-Settings-1","page":"Measurement Generator","title":"Run Settings","text":"","category":"section"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"The standalone measurement generator receives inputs for measurement variances, and inputs for measurement sets, to produce measurement data. There are two export formats supported for the measurement data, .h5 or .xlsx file. The settings are provided as input arguments of the function runmg(...).","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"The order of inputs and their appearance is arbitrary, with only DATA input required. Still, for the methodological reasons, the syntax examples follow a certain order.","category":"page"},{"location":"man/generator/#Syntax-1","page":"Measurement Generator","title":"Syntax","text":"","category":"section"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"runmg(DATA)\nrunmg(DATA; RUNPF)\nrunmg(DATA; RUNPF, SET)\nrunmg(DATA; RUNPF, SET, VARIANCE)\nrunmg(DATA; RUNPF, SET, VARIANCE, ACCONTROL)\nrunmg(DATA; RUNPF, SET, VARIANCE, ACCONTROL, SAVE)","category":"page"},{"location":"man/generator/#Description-1","page":"Measurement Generator","title":"Description","text":"","category":"section"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"runmg(DATA) computes the AC power flow problem and generates measurements\nrunmg(DATA; RUNPF) sets AC power flow analysis\nrunmg(DATA; RUNPF, SET) defines the measurement set (in-service and out-service)\nrunmg(DATA; RUNPF, SET, VARIANCE) defines measurement values using predefined variances\nrunmg(DATA; RUNPF, SET, VARIANCE, ACCONTROL) sets variables for the AC power flow\nrunmg(DATA; RUNPF, SET, VARIANCE, ACCONTROL, SAVE) exports measurements and power system data","category":"page"},{"location":"man/generator/#Output-1","page":"Measurement Generator","title":"Output","text":"","category":"section"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"results = runmg(...) returns measurement and power system data with a summary","category":"page"},{"location":"man/generator/#Examples-1","page":"Measurement Generator","title":"Examples","text":"","category":"section"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"julia> results = runmg(\"case14.xlsx\"; pmuset = \"optimal\")","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"julia> results = runmg(\"case14.xlsx\"; pmuset = [\"Iij\" 5 \"Vi\" 2])","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"julia> results = runmg(\"case14.xlsx\"; pmuset = [\"Iij\" \"all\" \"Vi\" 2], legacyset = [\"Pij\" 4 \"Qi\" 8])","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"julia> results = runmg(\"case14.h5\"; legacyset = [\"redundancy\" 3.1], legacyvariance = [\"all\" 1e-4])","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"julia> results = runmg(\"case14.h5\"; legacyset = \"all\", legacyvariance = [\"Pij\" 1e-4 \"all\" 1e-5])","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"","category":"page"},{"location":"man/generator/#Input-Arguments-1","page":"Measurement Generator","title":"Input Arguments","text":"","category":"section"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"The measurement generator function runmg(...) receives the variable number of argument DATA, and group of arguments by keyword: RUNPF, SET, VARIANCE, ACCONTROL and SAVE.","category":"page"},{"location":"man/generator/#Variable-Arguments-1","page":"Measurement Generator","title":"Variable Arguments","text":"","category":"section"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"DATA","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"Example Description\n\"case14.h5\" loads the power system data from the package\n\"case14.xlsx\" loads the power system data from the package\n\"C:/case14.xlsx\" loads the power system data from a custom path","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"","category":"page"},{"location":"man/generator/#Keyword-Arguments-1","page":"Measurement Generator","title":"Keyword Arguments","text":"","category":"section"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"RUNPF","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"Command Description\nrunpf = 1 forces the AC power flow analysis to generate measurements, default setting\nrunpf = 0 generates measurements directly from the input DATA","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"SET (phasor measurements)","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"Command Description\npmuset = \"all\" all phasor measurements are in-service\npmuset = \"optimal\" deploys phasor measurements according to the optimal PMU location using GLPK solver, where the system is completely observable only by phasor measurements\npmuset = [\"redundancy\" value] deploys random angle and magnitude measurements measured by PMUs according to the corresponding redundancy\npmuset = [\"device\" value] deploys voltage and current phasor measurements according to the random selection of PMUs placed on buses, to deploy all devices use \"all\" as value\npmuset = [\"Iij\" value \"Dij\" value \"Vi\" value \"Ti\" value] deploys phasor measurements according to the random selection of measurement types[1], to deploy all selected measurements use \"all\" as value","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"SET (legacy measurements)","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"Command Description\nlegacyset = \"all\" all legacy measurements are in-service\nlegacyset = [\"redundancy \" value] deploys random selection of legacy measurements according the corresponding redundancy\nlegacyset = [\"Pij\" value \"Qij\" value \"Iij\" value \"Pi\" value \"Qi\" value \"Vi\" value] deploys legacy measurements according to the random selection of measurement types[2], to deploy all selected measurements use \"all\" as value","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"note: Set\nIf runpf = 0, the function keeps sets as in the input DATA and changes only the sets that are called using keywords. For example, if the keywords pmuset and legacyset are omitted, the function will retain the measurement set as in the input data, which allows the same measurement set, while changing the measurement variances.If runpf = 1, the function starts with all the measurement sets marked as out-service.  Further, the function accept any subset of phasor[1] or legacy[2] measurements, and consequently, it is not necessary to define attributes for all measurements.  julia> runmg(\"case14.h5\"; pmuset = [\"Iij\" \"all\" \"Vi\" 2])Thus, the measurement set will consist of two randomly selected bus voltage magnitude measurements, and all branch current magnitude measurements, both of them related with PMUs.  ","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"VARIANCE (phasor measurements)","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"Command Description\npmuvariance = [\"all\" value] applies fixed-value variance over all phasor measurements\npmuvariance = [\"random\" min max] selects variances uniformly at random within limits, applied over all phasor measurements\npmuvariance = [\"Iij\" value \"Dij\" value \"Vi\" value \"Ti\" value \"all\" value] predefines variances over a given subset of phasor measurements[1]; to apply fixed-value variance over all, except for those individually defined use \"all\" value","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"VARIANCE (legacy measurements)","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"Command Description\nlegacyvariance = [\"all\" value] applies fixed-value variance over all phasor measurements\nlegacyvariance = [\"random\" min max] selects variances uniformly at random within limits, applied over all phasor measurements\nlegacyvariance = [\"Pij\" value \"Qij\" value \"Iij\" value \"Pi\" value \"Qi\" value \"Vi\" value \"all\" value] predefines variances over a given subset of phasor measurements[2], to apply fixed-value variance over all, except for those individually defined use \"all\" value","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"note: Variance\nIf runpf = 0, the function keeps measurement values and measurement variances as in the input DATA, and changes only measurement values and variances that are called using keywords. For example, if the keywords pmuvariance and legacyvariance are omitted, the function will retain the measurement values and variances as in the input data, allowing the same measurement values and variances, while changing the measurement sets.If runpf = 1, the function starts with zero variances, meaning that measurement values are equal to the exact values.Further, the function accepts any subset of phasor[1] or legacy[2] measurements, consequently, it is not necessary to define attributes for all measurements, where keyword \"all\" generates measurement values according to defined variance for all measurements, except for those individually defined.   julia> runmg(\"case14.h5\"; legacyvariance = [\"Pij\" 1e-4 \"all\" 1e-5])The function applies variance value of 1e-5 over all legacy measurements, except for active power flow measurements which have variance equal to 1e-4.","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"ACCONTROL","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"Command Description\nmax = value specifies the maximum number of iterations for the AC power flow, default setting: 100\nstop = value specifies the stopping criteria for the AC power flow, default setting: 1.0e-8\nreactive = 1 forces reactive power constraints, default setting: 0\nsolve = \"mldivide\" mldivide linear system solver, default setting\nsolve = \"lu\" LU linear system solver","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"SAVE","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"Command Description\nsave = \"path/name.h5\" saves results in the h5-file\nsave = \"path/name.xlsx\" saves results in the xlsx-file","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"","category":"page"},{"location":"man/generator/#Data-Structure-1","page":"Measurement Generator","title":"Data Structure","text":"","category":"section"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"The function supports the .h5 or .xlsx file extensions, with variables pmuVoltage and pmuCurrents associated with phasor measurements, and legacyFlow, \"legacyCurrent\", \"legacyInjection\" and \"legacyVoltage\" associated with legacy measurements. Further, the function requires knowledge about a power system using variables bus, branch, generator and \"basePower\" variables.","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"The minimum amount of information within an instance of the data structure required to run the module requires one variable associated with measurements if runflow = 0, and bus and branch variables.","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"Next, we describe the structure of measurement variables involved in the input/output file, while variables associated with a power system are described in Power Flow section.","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"The pmuVoltage data structure","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"Column Description Type Unit\n1 bus number positive integer \n2 measurement bus voltage magnitude per-unit\n3 variance bus voltage magnitude per-unit\n4 status bus voltage magnitude in/out-service \n5 measurement bus voltage angle radian\n6 variance bus voltage angle radian\n7 status bus voltage angle in/out-service \n8 exact bus voltage magnitude per-unit\n9 exact bus voltage angle radian\n10 label optional column ","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"The pmuCurrent data structure","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"Column Description Type Unit\n1 branch number positive integer \n2 from bus number positive integer \n3 to bus number positive integer \n4 measurement branch current magnitude per-unit\n5 variance branch current magnitude per-unit\n6 status branch current magnitude in/out-service \n7 measurement branch current angle radian\n8 variance branch current angle radian\n9 status branch current in/out-service \n10 exact branch current magnitude per-unit\n11 exact branch current angle radian\n12 label optional column ","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"note: Optional column: label\nThe optional column label is useful to use when several PMUs exist on a single bus, where labels used in the variable pmuCurrent should be consistent with labels in the variable pmuVoltage.  ","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"The legacyFlow data structure","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"Column Description Type Unit\n1 branch number positive integer \n2 from bus number positive integer \n3 to bus number positive integer \n4 measurement active power flow per-unit\n5 variance active power flow per-unit\n6 status active power flow in/out-service \n7 measurement reactive power flow per-unit\n8 variance reactive power flow per-unit\n9 status reactive power flow in/out-service \n10 exact active power flow per-unit\n11 exact reactive power flow per-unit","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"The legacyCurrent data structure","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"Column Description Type Unit\n1 branch number positive integer \n2 from bus number positive integer \n3 to bus number positive integer \n4 measurement branch current magnitude per-unit\n5 variance branch current magnitude per-unit\n6 status branch current magnitude in/out-service \n7 exact branch current magnitude per-unit","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"The legacyInjection data structure","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"Column Description Type Unit\n1 bus number positive integer \n2 measurement active power injection per-unit\n3 variance active power injection per-unit\n4 status active power injection in/out-service \n5 measurement reactive power injection per-unit\n6 variance reactive power injection per-unit\n7 status reactive power injection  in/out-service \n8 exact active power injection per-unit\n9 exact reactive power injection per-unit","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"The pmuVoltage data structure","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"Column Description Type Unit\n1 bus number positive integer \n2 measurement bus voltage magnitude per-unit\n3 variance bus voltage magnitude per-unit\n4 status bus voltage magnitude in/out-service \n5 exact bus voltage magnitude per-unit","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"tip: How many\nThe input data needs not to contain a complete structure of measurement variables, and measurement data needs not to be consistent with the total number of buses and branches. Also, the function supports more than one measurement per the same bus or branch.","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"","category":"page"},{"location":"man/generator/#Flowchart-1","page":"Measurement Generator","title":"Flowchart","text":"","category":"section"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"The measurement generator flowchart depicts the algorithm process according to user settings.","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"(Image: )","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"[1]: Complete phasor measurement set contains branch current magnitude Iij, branch current angle Dij, bus voltage magnitude Vi and bus voltage angle Ti measurements.","category":"page"},{"location":"man/generator/#","page":"Measurement Generator","title":"Measurement Generator","text":"[2]: Complete legacy measurement set contains active power flow Pij, reactive power flow Qij, branch current magnitude Iij, active power injection Pi, reactive power injection Qi and bus voltage magnitude Vi measurements.","category":"page"},{"location":"#JuliaGrid-1","page":"Home","title":"JuliaGrid","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"JuliaGrid is an open-source, easy-to-use simulation tool/solver for researchers and educators provided as a Julia package, with source code released under MIT License. JuliaGrid is inspired by the Matpower, an open-source steady-state power system solver,  and allows a variety of display and manipulation options.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"The software package, among other things, includes:","category":"page"},{"location":"#","page":"Home","title":"Home","text":"AC power flow analysis,\nDC power flow analysis,\nnon-linear state estimation (work in progress),\nlinear DC state estimation (work in progress),\nlinear state estimation with PMUs only (work in progress),\nleast absolute value state estimation (work in progress),\noptimal PMU placement,\nbad data processing (work in progress).","category":"page"},{"location":"#","page":"Home","title":"Home","text":"","category":"page"},{"location":"#Main-Features-1","page":"Home","title":"Main Features","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"Features supported by JuliaGrid can be categorised into three main groups:","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Power Flow - performs the AC and DC power flow analysis using the executive function runpf(...);\nState Estimation - performs non-linear, DC and PMU state estimation using the executive function runse(...), where measurement variances and sets can be changed (work in progress);\nStandalone Measurement Generator - generates a set of measurements according to the AC power flow analysis or predefined user data using the executive function runmg(...).","category":"page"},{"location":"#","page":"Home","title":"Home","text":"","category":"page"},{"location":"#Installation-1","page":"Home","title":"Installation","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"JuliaGrid requires Julia 1.3 and higher. To install JuliaGrid package, run the following command:","category":"page"},{"location":"#","page":"Home","title":"Home","text":"pkg> add https://github.com/mcosovic/JuliaGrid","category":"page"},{"location":"#","page":"Home","title":"Home","text":"To load the package, use the command:","category":"page"},{"location":"#","page":"Home","title":"Home","text":"julia> using JuliaGrid","category":"page"},{"location":"#","page":"Home","title":"Home","text":"","category":"page"},{"location":"#Quick-Start-Power-Flow-1","page":"Home","title":"Quick Start Power Flow","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"julia> results = runpf(\"dc\", \"case14.h5\", \"main\", \"flow\")","category":"page"},{"location":"#","page":"Home","title":"Home","text":"julia> results = runpf(\"nr\", \"case14.xlsx\", \"main\"; max = 20, stop = 1.0e-8)","category":"page"},{"location":"#Quick-Start-Measurement-Generator-1","page":"Home","title":"Quick Start Measurement Generator","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"julia> results = rungen(\"case14.h5\"; pmuset = \"optimal\", pmuvariance = [\"all\" 1e-5])","category":"page"},{"location":"#","page":"Home","title":"Home","text":"julia> results = rungen(\"case14.h5\"; legacyset = [\"redundancy\" 3.1], legacyvariance = [\"all\" 1e-4])","category":"page"}]
}
