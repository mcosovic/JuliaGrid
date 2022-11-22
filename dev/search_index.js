var documenterSearchIndex = {"docs":
[{"location":"man/powerSystemModelBuild/#inputdata","page":"Build Power System Model","title":"Build Power System Model","text":"","category":"section"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The main composite type PowerSystem with fields bus, branch, generator, acModel, dcModel, and basePower can be created using a function:","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"powerSystem().","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"Once the model is created, it is possible to add buses, branches and generators using functions:","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"addBus!()\naddBranch!()\naddGenerator!().","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The final step is the formation and saving of vectors and matrices obtained based on the power system topology and parameters using functions:","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"acModel!()\ndcModel!().","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"Note that, once the field acModel and dcModel are formed, using function addBranch!(), will automatically trigger the update of these fields. In contrast, adding a new bus, using addBus!(), requires executing the functions acModel!() and dcModel!() again.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"Then, it is possible to manipulate the parameters of buses, branches and generators using functions:","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"shuntBus!()\nstatusBranch!()\nparameterBranch!()\nstatusGenerator!()\noutputGenerator!().","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The execution of these functions will automatically trigger the update of all subtypes affected by these functions.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"<hr style=\"border:1px solid #CBCDCD; opacity: 0.5\">","category":"page"},{"location":"man/powerSystemModelBuild/#Build-Model","page":"Build Power System Model","title":"Build Model","text":"","category":"section"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The function powerSystem() builds the main composite type PowerSystem and populate fields bus, branch, generator and basePower.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"","category":"page"},{"location":"man/powerSystemModelBuild/#External-Files","page":"Build Power System Model","title":"External Files","text":"","category":"section"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"powerSystem(inputFile::String)","category":"page"},{"location":"man/powerSystemModelBuild/#JuliaGrid.powerSystem-Tuple{String}","page":"Build Power System Model","title":"JuliaGrid.powerSystem","text":"powerSystem(inputFile::String)\n\nThe path to the HDF5 file with .h5 extension should be passed to the function.  Similarly, the path to the Matpower file with .m extension should be passed to the same function. Then, it is possible to add new power system elements and manipulate the existing ones.\n\n\n\n\n\n","category":"method"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The path to the HDF5 file with .h5 extension should be passed to the function powerSystem():","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"system = powerSystem(\"pathToExternalData/name.h5\")","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"Similarly, the path to the Matpower file with .m extension should be passed to the same function:","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"system = powerSystem(\"pathToExternalData/name.m\")","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"Then, it is possible to add new power system elements and manipulate the existing ones, using the functions given below.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"","category":"page"},{"location":"man/powerSystemModelBuild/#Empty-Model","page":"Build Power System Model","title":"Empty Model","text":"","category":"section"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"By omitting the argument of the function powerSystem(), it is possible to initialize the main composite type PowerSystem:","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"system = powerSystem()","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"After that, it is possible to build a model from scratch using functions addBus!(), addBranch!(), and addGenerator!().","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"<hr style=\"border:1px solid #CBCDCD; opacity: 0.5\">","category":"page"},{"location":"man/powerSystemModelBuild/#Bus-Functions","page":"Build Power System Model","title":"Bus Functions","text":"","category":"section"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"Functions receives the main composite type PowerSystem and arguments by keyword to set or change bus parameters, and affect field bus.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"","category":"page"},{"location":"man/powerSystemModelBuild/#Adding-Bus","page":"Build Power System Model","title":"Adding Bus","text":"","category":"section"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The function addBus!() add the new bus. Names, descriptions and units of keywords are given in the table bus group.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"addBus!(system; label, slackLabel, lossZone, area, active, reactive, conductance,\n    susceptance, magnitude, angle, minMagnitude, maxMagnitude, base)","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The keyword label is mandatory. Default keyword values are set to zero, except for keywords lossZone = 1, area = 1, magnitude = 1.0, minMagnitude = 0.9, and maxMagnitude = 1.1. The slack bus, using the keyword slackLabel(), can be specified in each function call with the label of the bus being defined or already existing. If the bus is not defined as the slack, the function addBus!() automatically defines the bus as the demand bus (PQ). If a generator is connected to a bus, using the function addGenerator!(), the bus becomes a generator bus (PV).","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"","category":"page"},{"location":"man/powerSystemModelBuild/#Change-Parameters-of-the-Shunt-Element","page":"Build Power System Model","title":"Change Parameters of the Shunt Element","text":"","category":"section"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The function shuntBus!() allows changing conductance and susceptance parameters of the shunt element connected to the bus.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"shuntBus!(system; label, conductance, susceptance)","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The keywords label should correspond to the already defined bus label. Keywords conductance or susceptance can be omitted, then the value of the omitted parameter remains unchanged. The function also updates the field acModel, if field exist.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"<hr style=\"border:1px solid #CBCDCD; opacity: 0.5\">","category":"page"},{"location":"man/powerSystemModelBuild/#Branch-Functions","page":"Build Power System Model","title":"Branch Functions","text":"","category":"section"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"Functions receives the main composite type PowerSystem and arguments by keyword to set or change branch parameters. Further, functions affect field branch, but also fields acModel and dcModel. More precisely, once acModel and dcModel are created, the execution of functions will automatically trigger the update of these fields.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"","category":"page"},{"location":"man/powerSystemModelBuild/#Adding-Branch","page":"Build Power System Model","title":"Adding Branch","text":"","category":"section"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The function addBranch!() add the new branch. Names, descriptions and units of keywords are given in the table branch group. A branch can be added between already defined buses.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"addBranch!(system; label, from, to, status, resistance, reactance, susceptance, turnsRatio,\n    shiftAngle, minAngleDifference, maxAngleDifference, longTerm, shortTerm, emergency)","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The keywords label, from, to, and one of the parameters resistance or reactance are mandatory. Default keyword values are set to zero, except for keywords status = 1, minAngleDifference = -2pi, maxAngleDifference = 2pi.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"","category":"page"},{"location":"man/powerSystemModelBuild/#Change-Operating-Status","page":"Build Power System Model","title":"Change Operating Status","text":"","category":"section"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The function statusBranch!() allows changing the operating status of the branch, from in-service to out-of-service, and vice versa.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"statusBranch!(system; label, status)","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The keywords label should correspond to the already defined branch label.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"","category":"page"},{"location":"man/powerSystemModelBuild/#Change-Parameters","page":"Build Power System Model","title":"Change Parameters","text":"","category":"section"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The function parameterBranch! allows changing resistance, reactance, susceptance, turnsRatio and shiftAngle parameters of the branch.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"parameterBranch!(system; label, resistance, reactance, susceptance, turnsRatio, shiftAngle)","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The keywords label should correspond to the already defined branch label. Keywords resistance, reactance, susceptance, turnsRatio or shiftAngle can be omitted, then the value of the omitted parameter remains unchanged.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"<hr style=\"border:1px solid #CBCDCD; opacity: 0.5\">","category":"page"},{"location":"man/powerSystemModelBuild/#Generator-Functions","page":"Build Power System Model","title":"Generator Functions","text":"","category":"section"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"Functions receives the main composite type PowerSystem and arguments by keyword to set or change generator parameters. Further, functions affect fields generator and bus.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"","category":"page"},{"location":"man/powerSystemModelBuild/#Adding-Generators","page":"Build Power System Model","title":"Adding Generators","text":"","category":"section"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The function addGenerator!() add the new generator. Names, descriptions and units of keywords are given in the table generator group. A generator can be added at already defined bus.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"addGenerator!(system; label, bus, status, area, active, reactive, magnitude, minActive,\n    maxActive, minReactive, maxReactive, lowerActive, minReactiveLower, maxReactiveLower,\n    upperActive, minReactiveUpper, maxReactiveUpper, loadFollowing, reserve10minute,\n    reserve30minute, reactiveTimescale, activeModel, activeStartup, activeShutdown,\n    activeDataPoint, activeCoefficient, reactiveModel, reactiveStartup, reactiveShutdown,\n    reactiveDataPoint, reactiveCoefficient)","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The keywords label and bus are mandatory. Default keyword values are set to zero, except for keywords status = 1, magnitude = 1.0, maxActive = Inf, minReactive = -Inf, maxReactive = Inf, activeModel = 2, activeDataPoint = 3, reactiveModel = 2, and reactiveDataPoint = 3.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"","category":"page"},{"location":"man/powerSystemModelBuild/#Change-Operating-Status-2","page":"Build Power System Model","title":"Change Operating Status","text":"","category":"section"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The function statusGenerator!() allows changing the operating status of the generator, from in-service to out-of-service, and vice versa.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"statusGenerator!(system; label, status)","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The keywords label should correspond to the already defined generator label.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"","category":"page"},{"location":"man/powerSystemModelBuild/#Change-Power-Output","page":"Build Power System Model","title":"Change Power Output","text":"","category":"section"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The function outputGenerator!() allows changing active and reactive output power of the generator.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"outputGenerator!(system; label, active, reactive)","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The keywords label should correspond to the already defined generator label. Keywords active or reactive can be omitted, then the value of the omitted parameter remains unchanged.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"<hr style=\"border:1px solid #CBCDCD; opacity: 0.5\">","category":"page"},{"location":"man/powerSystemModelBuild/#Build-AC-Model","page":"Build Power System Model","title":"Build AC Model","text":"","category":"section"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The function acModel!() receives the main composite type PowerSystem and forms vectors and matrices related with AC simulations:","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"acModel!(system)","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The function affects field acModel. Once formed, the field will be automatically updated when using functions addBranch!(), shuntBus!(), statusBranch!() parameterBranch!(). We advise the reader to read the section in-depth AC Model, that explains all the data involved in the field acModel.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"<hr style=\"border:1px solid #CBCDCD; opacity: 0.5\">","category":"page"},{"location":"man/powerSystemModelBuild/#Build-DC-Model","page":"Build Power System Model","title":"Build DC Model","text":"","category":"section"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The function dcModel!() receives the main composite type PowerSystem and forms vectors and matrices related with DC simulations:","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"dcModel!(system)","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"The function affects field acModel. Once formed, the field will be automatically updated when using functions addBranch!(), statusBranch!() parameterBranch!(). We advise the reader to read the section in-depth DC Model, that explains all the data involved in the field dcModel.","category":"page"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"<hr style=\"border:1px solid #CBCDCD; opacity: 0.5\">","category":"page"},{"location":"man/powerSystemModelBuild/#Modifying-Other-Parameters","page":"Build Power System Model","title":"Modifying Other Parameters","text":"","category":"section"},{"location":"man/powerSystemModelBuild/","page":"Build Power System Model","title":"Build Power System Model","text":"Changing other parameters of the power system can be done by changing variables by accessing their values in fields bus, branch and generator of the main type powerSystem.","category":"page"},{"location":"#JuliaGrid","page":"Home","title":"JuliaGrid","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"JuliaGrid is an open-source, easy-to-use simulation tool/solver for researchers and educators provided as a Julia package, with source code released under MIT License. JuliaGrid is inspired by the Matpower, an open-source steady-state power system solver, and allows a variety of display and manipulation options.","category":"page"},{"location":"man/powerSystemModel/#powerSystemModel","page":"Power System Model","title":"Power System Model","text":"","category":"section"},{"location":"man/powerSystemModel/","page":"Power System Model","title":"Power System Model","text":"The JuliaGrid supports the main composite type PowerSystem to preserve power system data, with fields:","category":"page"},{"location":"man/powerSystemModel/","page":"Power System Model","title":"Power System Model","text":"bus\nbranch\ngenerator\nacModel\ndcModel\nbasePower.","category":"page"},{"location":"man/powerSystemModel/","page":"Power System Model","title":"Power System Model","text":"The fields bus, branch, generator hold the data related with buses, branches and generators, respectively. Subtypes acModel and dcModel store vectors and matrices obtained based on the power system topology and parameters. The base power of the system is kept in the field basePower, given in volt-ampere unit.","category":"page"},{"location":"man/powerSystemModel/","page":"Power System Model","title":"Power System Model","text":"The function powerSystem() returns the main composite type PowerSystem with all subtypes.","category":"page"},{"location":"man/powerSystemModel/","page":"Power System Model","title":"Power System Model","text":"JuliaGrid supports three modes of forming the power system model:","category":"page"},{"location":"man/powerSystemModel/","page":"Power System Model","title":"Power System Model","text":"using built-in functions,\nusing HDF5 file format,\nusing Matpower case files.","category":"page"},{"location":"man/powerSystemModel/","page":"Power System Model","title":"Power System Model","text":"Note that, in the case of large-scale systems, we strongly recommend to use the HDF5 file format for the input. Therefore, JuliaGrid has the function that any system loaded from Matpower case files or a system formed using built-in functions can be saved in the HDF5 format.","category":"page"},{"location":"man/powerSystemModel/","page":"Power System Model","title":"Power System Model","text":"The HDF5 file format contains three groups: bus, branch and generator. In addition, the file contains basePower variable, given in volt-ampere. Each group is divided into subgroups that gather the same type of physical quantities, with the corresponding datasets. Note that, dataset names are identical to the keywords, which are used when the power system model is formed using built-in functions.","category":"page"},{"location":"man/powerSystemModel/","page":"Power System Model","title":"Power System Model","text":"<hr style=\"border:1px solid #CBCDCD; opacity: 0.5\">","category":"page"},{"location":"man/powerSystemModel/#busGroup","page":"Power System Model","title":"Bus Group","text":"","category":"section"},{"location":"man/powerSystemModel/","page":"Power System Model","title":"Power System Model","text":"The bus group is divided into four subgroups: layout, demand, shunt, and voltage. Each of the subgroups contains datasets that define features of the buses.","category":"page"},{"location":"man/powerSystemModel/","page":"Power System Model","title":"Power System Model","text":"Subgroup Dataset Description Unit Type\nlayout label unique bus label - positive integer\nlayout slackLabel bus label of the slack bus - positive integer\nlayout lossZone loss zone - positive integer\nlayout area area number - positive integer\ndemand active active power demand per-unit float\ndemand reactive reactive power demand per-unit float\nshunt conductance active power demanded of the shunt element at voltage magnitude equal to 1 per-unit per-unit float\nshunt susceptance reactive power injected of the shunt element at voltage magnitude equal to 1 per-unit per-unit float\nvoltage magnitude initial value of the voltage magnitude per-unit float\nvoltage angle initial value of the voltage angle radian float\nvoltage minMagnitude minimum allowed voltage magnitude value per-unit float\nvoltage maxMagnitude maximum allowed voltage magnitude value per-unit float\nvoltage base base value of the voltage magnitude volt float","category":"page"},{"location":"man/powerSystemModel/","page":"Power System Model","title":"Power System Model","text":"<hr style=\"border:1px solid #CBCDCD; opacity: 0.5\">","category":"page"},{"location":"man/powerSystemModel/#branchGroup","page":"Power System Model","title":"Branch Group","text":"","category":"section"},{"location":"man/powerSystemModel/","page":"Power System Model","title":"Power System Model","text":"The branch group is divided into four subgroups: layout, parameter, voltage, and rating. Each of the subgroups contains datasets that define features of the branches.","category":"page"},{"location":"man/powerSystemModel/","page":"Power System Model","title":"Power System Model","text":"Subgroup Dataset Description Unit Type\nlayout label unique branch label - positive integer\nlayout from from bus label (corresponds to the bus label) - positive integer\nlayout to to bus label (corresponds to the bus label) - positive integer\nlayout status operating status of the branch, in-service = 1, out-of-service = 0 - zero-one integer\nparameter resistance branch resistance per-unit float\nparameter reactance branch reactance per-unit float\nparameter susceptance total line charging susceptance per-unit float\nparameter turnsRatio transformer off-nominal turns ratio, equal to zero for a line - float\nparameter shiftAngle transformer phase shift angle where positive value defines delay radian float\nvoltage minAngleDifference minimum allowed voltage angle difference value between from and to bus radian float\nvoltage maxAngleDifference maximum allowed voltage angle difference value between from and to bus radian float\nrating shortTerm short term rating (equal to zero for unlimited) per-unit float\nrating longTerm long term rating (equal to zero for unlimited) per-unit float\nrating emergency emergency rating (equal to zero for unlimited) per-unit positive integer","category":"page"},{"location":"man/powerSystemModel/","page":"Power System Model","title":"Power System Model","text":"<hr style=\"border:1px solid #CBCDCD; opacity: 0.5\">","category":"page"},{"location":"man/powerSystemModel/#generatorGroup","page":"Power System Model","title":"Generator Group","text":"","category":"section"},{"location":"man/powerSystemModel/","page":"Power System Model","title":"Power System Model","text":"The generator group is divided into six subgroups: layout, output, voltage, capability, ramRate, and cost. Each of the subgroups contains datasets that define features of the generators.","category":"page"},{"location":"man/powerSystemModel/","page":"Power System Model","title":"Power System Model","text":"Subgroup Dataset Description Unit Type\nlayout label unique generator label - positive integer\nlayout bus bus label to which the generator is connected - positive integer\nlayout status operating status of the generator, in-service = 1, out-of-service = 0 - zero-one integer\nlayout area area participation factor - float\noutput active output active power of the generator per-unit float\noutput reactive output reactive power of the generator per-unit float\nvoltage magnitude voltage magnitude setpoint per-unit float\ncapability minActive minimum allowed output active power value of the generator per-unit float\ncapability maxActive maximum allowed output active power value of the generator per-unit float\ncapability minReactive minimum allowed output reactive power value of the generator per-unit float\ncapability maxReactive maximum allowed output reactive power value of the generator per-unit float\ncapability lowerActive lower allowed active power output value of PQ capability curve per-unit float\ncapability minReactiveLower minimum allowed reactive power output value at lowerActive value per-unit float\ncapability maxReactiveLower maximum allowed reactive power output value at lowerActive value per-unit float\ncapability upperActive upper allowed active power output value of PQ capability curve per-unit float\ncapability minReactiveUpper minimum allowed reactive power output value at upperActive value per-unit float\ncapability maxReactiveUpper maximum allowed reactive power output value at upperActive value per-unit float\nrampRate loadFollowing ramp rate for load following/AGC per-unit/minute float\nrampRate reserve10minute ramp rate for 10-minute reserves per-unit float\nrampRate reserve30minute ramp rate for 30-minute reserves per-unit float\nrampRate reactiveTimescale ramp rate for reactive power (two seconds timescale) per-unit/minute float\ncost activeModel active power cost model, piecewise linear = 1, polynomial = 2 - one-two integer\ncost activeStartup active power startup cost currency float\ncost activeShutdown active power shutdown cost currency float\ncost activeDataPoint number of data points for active power cost model - positive integer\ncost activeCoefficient coefficients for forming the active power cost function (*) float\ncost reactiveModel reactive power cost model, piecewise linear = 1, polynomial = 2 - one-two integer\ncost reactiveStartup reactive power startup cost currency float\ncost reactiveShutdown reactive power shutdown cost currency float\ncost reactiveDataPoint number of data points for reactive power cost model - positive integer\ncost reactiveCoefficient coefficients for forming the reactive power cost function (*) float","category":"page"},{"location":"man/powerSystemModel/","page":"Power System Model","title":"Power System Model","text":"","category":"page"},{"location":"man/powerSystemModel/","page":"Power System Model","title":"Power System Model","text":"The interpretation of the datasets activeCoefficient and reactiveCoefficient, given as matrices, depends on the activeModel and reactiveModel that is selected:","category":"page"},{"location":"man/powerSystemModel/","page":"Power System Model","title":"Power System Model","text":"piecewise linear cost model is defined according to input-output points, where the i-th row of the matrix is given as:\nactiveCoefficient: p_1 f(p_1) p_2 f(p_2) dots p_n f(p_n),\nreactiveCoefficient: q_1 f(q_1) q_2 f(q_2) dots q_n f(q_n).\npolynomial cost model is defined using the n-th degree polynomial, where the i-th row of the matrix is given as:\nactiveCoefficient: a_n dots a_1 a_0 to define f(p) = a_n p^n + dots + a_1 p + a_0,\nreactiveCoefficient: b_n dots b_1 b_0 to define f(q) = b_n q^n + dots + b_1 q + b_0.","category":"page"},{"location":"man/powerSystemModel/","page":"Power System Model","title":"Power System Model","text":"(*) Thus, for the piecewise linear model p_i and q_i are given in per-unit, while f(p_i) and f(q_i) have a dimension of currency/hour. In the polynomial model coefficients are dimensionless.","category":"page"}]
}
