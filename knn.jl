using CSV

function readData(str, types)
	if (isempty(types))
		return CSV.File(str)
	else
		return CSV.File(str; types=types,silencewarnings=true)	
	end
end

function splitData(data, prbl)
	train = CSV.Row[]
	test = CSV.Row[]

	for row in data
		if (rand() <= prbl)
			push!(train,row)
		else
			push!(test,row)
		end
	end

	train, test
end

function distData(a, b, props)
	n = size(props,1)

	p = 0.0
	for i in props
		p += abs(a[i] - b[i])^n
	end

	p = p^(1/n)
end

function getNeighs(a, data, k, props, answers)
	# Получаем точки в виде [расстояние, [ответы]]
	neighs = map(function(el) 
		ans = []
		for j in answers
			push!(ans, el[j]) 
		end
		(distData(a,el,props), ans...)
	end, data)
	# Сортируем по расстоянию
	neighs = sort(neighs)
	neighs = neighs[1:k]

	neighs
end

function getClasses(data, answers)
	classes = Set([])

	# Класс — это набор из **различных** ответов, храним их в множестве
	for row in data
		ans = []
		for j in answers
			push!(ans, row[j])
		end
		push!(classes, tuple(ans...))
	end

	classes
end

function triangleCoreFunc(r)
	1 - abs(r)
end

function getWeight(dist, distMax, coreFunc)
	coreFunc(dist/distMax)
end

function classiOne(a, data, k, classes, props, answers)
	neighs = getNeighs(a, data, k, props, answers)

	distMax = neighs[k][1]
	results = []
	for class in classes
		nums = 0
		for i in 1:k
			nums += (neighs[i][2:end] == class) * getWeight(neighs[i][1], distMax, triangleCoreFunc)
		end
		push!(results, (nums, class))
	end
	# Возвращаем класс в виде набор ответов
	sort(results, rev=true)[1][2]
end

function classiData(test, data, k, classes, props, answers)
	map(el -> classiOne(el, data, k, classes, props, answers), test)
end

function checkPredict(test, data, k, classes, props, answers)
	r = zeros(Bool, size(test,1))
	map!(function(el)
		ans = []
		for j in answers
			push!(ans, el[j])
		end
	
		tuple(ans...) == classiOne(el, data, k, classes, props, answers)
	end, r, test);
	
	sum(r) / size(r,1)
end

data = readData("data.csv", [Float64, Float64, String, String, Float64, Float64, String, String, String, String, String, String, Float64, String,  Float64, String, String, String, Float64, Float64, Float64, Float64, Float64, Float64, Float64, Float64, String, String, Float64, Float64, String, Float64, Float64, Float64])
train, test = splitData(data, 0.99)

println(size(data),":",size(train),":",size(test))

classes = getClasses(data, [2])
r = checkPredict(test, train, 3, classes, [15], [2])
println(r)



