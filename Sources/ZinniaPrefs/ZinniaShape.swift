import SwiftUI

struct ZinniaShape: Shape {
	func path(in rect: CGRect) -> Path {
		var path = Path()
		let width = rect.size.width
		let height = rect.size.height
		path.move(to: CGPoint(x: 0.44355 * width, y: 0.35853 * height))
		path.addCurve(
			to: CGPoint(x: 0.37679 * width, y: 0.24884 * height),
			control1: CGPoint(x: 0.39903 * width, y: 0.31393 * height),
			control2: CGPoint(x: 0.38822 * width, y: 0.28231 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.31645 * width, y: 0.14629 * height),
			control1: CGPoint(x: 0.36604 * width, y: 0.21738 * height),
			control2: CGPoint(x: 0.35493 * width, y: 0.18484 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.14674 * width, y: 0.14616 * height),
			control1: CGPoint(x: 0.2602 * width, y: 0.08995 * height),
			control2: CGPoint(x: 0.20309 * width, y: 0.08993 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.14661 * width, y: 0.31587 * height),
			control1: CGPoint(x: 0.0904 * width, y: 0.20241 * height),
			control2: CGPoint(x: 0.09035 * width, y: 0.25951 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.24905 * width, y: 0.37637 * height),
			control1: CGPoint(x: 0.18508 * width, y: 0.35441 * height),
			control2: CGPoint(x: 0.2176 * width, y: 0.36557 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.35864 * width, y: 0.44332 * height),
			control1: CGPoint(x: 0.28251 * width, y: 0.38786 * height),
			control2: CGPoint(x: 0.31411 * width, y: 0.39872 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.38044 * width, y: 0.44768 * height),
			control1: CGPoint(x: 0.36453 * width, y: 0.44921 * height),
			control2: CGPoint(x: 0.37318 * width, y: 0.45068 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.38692 * width, y: 0.44334 * height),
			control1: CGPoint(x: 0.3828 * width, y: 0.4467 * height),
			control2: CGPoint(x: 0.38501 * width, y: 0.44525 * height)
		)
		path.addLine(to: CGPoint(x: 0.44353 * width, y: 0.38682 * height))
		path.addCurve(
			to: CGPoint(x: 0.44355 * width, y: 0.35853 * height),
			control1: CGPoint(x: 0.45134 * width, y: 0.37901 * height),
			control2: CGPoint(x: 0.45135 * width, y: 0.36635 * height)
		)
		path.closeSubpath()
		path.move(to: CGPoint(x: 0.8534 * width, y: 0.68413 * height))
		path.addCurve(
			to: CGPoint(x: 0.75095 * width, y: 0.62363 * height),
			control1: CGPoint(x: 0.81492 * width, y: 0.64559 * height),
			control2: CGPoint(x: 0.7824 * width, y: 0.63443 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.64137 * width, y: 0.55668 * height),
			control1: CGPoint(x: 0.7175 * width, y: 0.61214 * height),
			control2: CGPoint(x: 0.6859 * width, y: 0.60128 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.61308 * width, y: 0.55666 * height),
			control1: CGPoint(x: 0.63357 * width, y: 0.54887 * height),
			control2: CGPoint(x: 0.62087 * width, y: 0.54884 * height)
		)
		path.addLine(to: CGPoint(x: 0.55647 * width, y: 0.61318 * height))
		path.addCurve(
			to: CGPoint(x: 0.55645 * width, y: 0.64146 * height),
			control1: CGPoint(x: 0.54866 * width, y: 0.62098 * height),
			control2: CGPoint(x: 0.54865 * width, y: 0.63364 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.62321 * width, y: 0.75115 * height),
			control1: CGPoint(x: 0.60097 * width, y: 0.68606 * height),
			control2: CGPoint(x: 0.61178 * width, y: 0.71768 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.68355 * width, y: 0.8537 * height),
			control1: CGPoint(x: 0.63396 * width, y: 0.78261 * height),
			control2: CGPoint(x: 0.64507 * width, y: 0.81515 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.8038 * width, y: 0.88869 * height),
			control1: CGPoint(x: 0.72341 * width, y: 0.89361 * height),
			control2: CGPoint(x: 0.76367 * width, y: 0.90527 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.85326 * width, y: 0.85383 * height),
			control1: CGPoint(x: 0.82032 * width, y: 0.88186 * height),
			control2: CGPoint(x: 0.83682 * width, y: 0.87024 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.8534 * width, y: 0.68413 * height),
			control1: CGPoint(x: 0.90961 * width, y: 0.79759 * height),
			control2: CGPoint(x: 0.90965 * width, y: 0.74049 * height)
		)
		path.closeSubpath()
		path.move(to: CGPoint(x: 0.44334 * width, y: 0.61308 * height))
		path.addLine(to: CGPoint(x: 0.38682 * width, y: 0.55647 * height))
		path.addCurve(
			to: CGPoint(x: 0.35853 * width, y: 0.55645 * height),
			control1: CGPoint(x: 0.37901 * width, y: 0.54866 * height),
			control2: CGPoint(x: 0.36636 * width, y: 0.54864 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.24884 * width, y: 0.62321 * height),
			control1: CGPoint(x: 0.31395 * width, y: 0.60098 * height),
			control2: CGPoint(x: 0.28233 * width, y: 0.61177 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.14629 * width, y: 0.68355 * height),
			control1: CGPoint(x: 0.21738 * width, y: 0.63396 * height),
			control2: CGPoint(x: 0.18484 * width, y: 0.64507 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.14616 * width, y: 0.85326 * height),
			control1: CGPoint(x: 0.08996 * width, y: 0.73981 * height),
			control2: CGPoint(x: 0.08992 * width, y: 0.79691 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.26641 * width, y: 0.88825 * height),
			control1: CGPoint(x: 0.18601 * width, y: 0.89318 * height),
			control2: CGPoint(x: 0.22627 * width, y: 0.90483 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.31587 * width, y: 0.85339 * height),
			control1: CGPoint(x: 0.28293 * width, y: 0.88142 * height),
			control2: CGPoint(x: 0.29944 * width, y: 0.8698 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.37637 * width, y: 0.75095 * height),
			control1: CGPoint(x: 0.35441 * width, y: 0.81492 * height),
			control2: CGPoint(x: 0.36557 * width, y: 0.7824 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.44332 * width, y: 0.64136 * height),
			control1: CGPoint(x: 0.38786 * width, y: 0.71749 * height),
			control2: CGPoint(x: 0.39872 * width, y: 0.68589 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.44334 * width, y: 0.61308 * height),
			control1: CGPoint(x: 0.45113 * width, y: 0.63356 * height),
			control2: CGPoint(x: 0.45114 * width, y: 0.6209 * height)
		)
		path.closeSubpath()
		path.move(to: CGPoint(x: 0.85384 * width, y: 0.14673 * height))
		path.addCurve(
			to: CGPoint(x: 0.68413 * width, y: 0.1466 * height),
			control1: CGPoint(x: 0.79761 * width, y: 0.09038 * height),
			control2: CGPoint(x: 0.74052 * width, y: 0.09033 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.62363 * width, y: 0.24904 * height),
			control1: CGPoint(x: 0.64559 * width, y: 0.18508 * height),
			control2: CGPoint(x: 0.63443 * width, y: 0.21759 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.55668 * width, y: 0.35863 * height),
			control1: CGPoint(x: 0.61214 * width, y: 0.2825 * height),
			control2: CGPoint(x: 0.60128 * width, y: 0.3141 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.55666 * width, y: 0.38692 * height),
			control1: CGPoint(x: 0.54886 * width, y: 0.36644 * height),
			control2: CGPoint(x: 0.54885 * width, y: 0.3791 * height)
		)
		path.addLine(to: CGPoint(x: 0.61318 * width, y: 0.44353 * height))
		path.addCurve(
			to: CGPoint(x: 0.63498 * width, y: 0.44788 * height),
			control1: CGPoint(x: 0.61907 * width, y: 0.44942 * height),
			control2: CGPoint(x: 0.62773 * width, y: 0.45088 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.64146 * width, y: 0.44354 * height),
			control1: CGPoint(x: 0.63734 * width, y: 0.44691 * height),
			control2: CGPoint(x: 0.63954 * width, y: 0.44546 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.75116 * width, y: 0.37679 * height),
			control1: CGPoint(x: 0.68607 * width, y: 0.39903 * height),
			control2: CGPoint(x: 0.71772 * width, y: 0.38823 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.8537 * width, y: 0.31645 * height),
			control1: CGPoint(x: 0.78261 * width, y: 0.36604 * height),
			control2: CGPoint(x: 0.81516 * width, y: 0.35492 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.85384 * width, y: 0.14673 * height),
			control1: CGPoint(x: 0.91004 * width, y: 0.26018 * height),
			control2: CGPoint(x: 0.91008 * width, y: 0.20309 * height)
		)
		path.closeSubpath()
		path.move(to: CGPoint(x: 0.36006 * width, y: 0.43989 * height))
		path.addCurve(
			to: CGPoint(x: 0.23527 * width, y: 0.40953 * height),
			control1: CGPoint(x: 0.29703 * width, y: 0.43984 * height),
			control2: CGPoint(x: 0.26703 * width, y: 0.42512 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.12011 * width, y: 0.37968 * height),
			control1: CGPoint(x: 0.20542 * width, y: 0.39488 * height),
			control2: CGPoint(x: 0.17456 * width, y: 0.37973 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0, y: 0.49958 * height),
			control1: CGPoint(x: 0.04043 * width, y: 0.37961 * height),
			control2: CGPoint(x: 0.00006 * width, y: 0.41997 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.1199 * width, y: 0.61969 * height),
			control1: CGPoint(x: -0.00005 * width, y: 0.5792 * height),
			control2: CGPoint(x: 0.04028 * width, y: 0.61961 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.23513 * width, y: 0.59003 * height),
			control1: CGPoint(x: 0.17434 * width, y: 0.61973 * height),
			control2: CGPoint(x: 0.20524 * width, y: 0.60467 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.35995 * width, y: 0.55988 * height),
			control1: CGPoint(x: 0.2669 * width, y: 0.57451 * height),
			control2: CGPoint(x: 0.29692 * width, y: 0.55984 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.3676 * width, y: 0.55838 * height),
			control1: CGPoint(x: 0.36266 * width, y: 0.55988 * height),
			control2: CGPoint(x: 0.36524 * width, y: 0.55935 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.37997 * width, y: 0.5399 * height),
			control1: CGPoint(x: 0.37486 * width, y: 0.55538 * height),
			control2: CGPoint(x: 0.37995 * width, y: 0.54823 * height)
		)
		path.addLine(to: CGPoint(x: 0.38003 * width, y: 0.4599 * height))
		path.addCurve(
			to: CGPoint(x: 0.36006 * width, y: 0.43989 * height),
			control1: CGPoint(x: 0.38005 * width, y: 0.44886 * height),
			control2: CGPoint(x: 0.3711 * width, y: 0.4399 * height)
		)
		path.closeSubpath()
		path.move(to: CGPoint(x: 0.8801 * width, y: 0.38031 * height))
		path.addCurve(
			to: CGPoint(x: 0.76487 * width, y: 0.40996 * height),
			control1: CGPoint(x: 0.82566 * width, y: 0.38026 * height),
			control2: CGPoint(x: 0.79478 * width, y: 0.39534 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.64005 * width, y: 0.44011 * height),
			control1: CGPoint(x: 0.73309 * width, y: 0.42549 * height),
			control2: CGPoint(x: 0.70309 * width, y: 0.44016 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.62003 * width, y: 0.46009 * height),
			control1: CGPoint(x: 0.62897 * width, y: 0.44011 * height),
			control2: CGPoint(x: 0.62004 * width, y: 0.44905 * height)
		)
		path.addLine(to: CGPoint(x: 0.61996 * width, y: 0.54009 * height))
		path.addCurve(
			to: CGPoint(x: 0.63994 * width, y: 0.56011 * height),
			control1: CGPoint(x: 0.61995 * width, y: 0.55114 * height),
			control2: CGPoint(x: 0.6289 * width, y: 0.5601 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.76473 * width, y: 0.59046 * height),
			control1: CGPoint(x: 0.70297 * width, y: 0.56016 * height),
			control2: CGPoint(x: 0.73297 * width, y: 0.57488 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.87989 * width, y: 0.62031 * height),
			control1: CGPoint(x: 0.79458 * width, y: 0.60511 * height),
			control2: CGPoint(x: 0.82544 * width, y: 0.62027 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.93953 * width, y: 0.61008 * height),
			control1: CGPoint(x: 0.90312 * width, y: 0.62033 * height),
			control2: CGPoint(x: 0.923 * width, y: 0.61691 * height)
		)
		path.addCurve(
			to: CGPoint(x: width, y: 0.50041 * height),
			control1: CGPoint(x: 0.97966 * width, y: 0.5935 * height),
			control2: CGPoint(x: 0.99995 * width, y: 0.5568 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.8801 * width, y: 0.38031 * height),
			control1: CGPoint(x: 1.00005 * width, y: 0.42079 * height),
			control2: CGPoint(x: 0.95971 * width, y: 0.38038 * height)
		)
		path.closeSubpath()
		path.move(to: CGPoint(x: 0.5399 * width, y: 0.62003 * height))
		path.addLine(to: CGPoint(x: 0.45991 * width, y: 0.61996 * height))
		path.addCurve(
			to: CGPoint(x: 0.43989 * width, y: 0.63994 * height),
			control1: CGPoint(x: 0.44882 * width, y: 0.61995 * height),
			control2: CGPoint(x: 0.4399 * width, y: 0.6289 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.40953 * width, y: 0.76471 * height),
			control1: CGPoint(x: 0.43984 * width, y: 0.70297 * height),
			control2: CGPoint(x: 0.42511 * width, y: 0.73296 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.37969 * width, y: 0.87989 * height),
			control1: CGPoint(x: 0.39488 * width, y: 0.79457 * height),
			control2: CGPoint(x: 0.37974 * width, y: 0.82543 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.4003 * width, y: 0.95901 * height),
			control1: CGPoint(x: 0.37967 * width, y: 0.90162 * height),
			control2: CGPoint(x: 0.38179 * width, y: 0.93346 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.49959 * width, y: height),
			control1: CGPoint(x: 0.41999 * width, y: 0.98617 * height),
			control2: CGPoint(x: 0.45339 * width, y: 0.99996 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.55921 * width, y: 0.98977 * height),
			control1: CGPoint(x: 0.52282 * width, y: 1.00002 * height),
			control2: CGPoint(x: 0.5427 * width, y: 0.9966 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.61969 * width, y: 0.8801 * height),
			control1: CGPoint(x: 0.59934 * width, y: 0.97319 * height),
			control2: CGPoint(x: 0.61963 * width, y: 0.93649 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.59004 * width, y: 0.76487 * height),
			control1: CGPoint(x: 0.61973 * width, y: 0.82563 * height),
			control2: CGPoint(x: 0.60463 * width, y: 0.79474 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.55989 * width, y: 0.64005 * height),
			control1: CGPoint(x: 0.57451 * width, y: 0.73309 * height),
			control2: CGPoint(x: 0.55984 * width, y: 0.70307 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.5399 * width, y: 0.62003 * height),
			control1: CGPoint(x: 0.55989 * width, y: 0.629 * height),
			control2: CGPoint(x: 0.55095 * width, y: 0.62004 * height)
		)
		path.closeSubpath()
		path.move(to: CGPoint(x: 0.50042 * width, y: 0))
		path.addCurve(
			to: CGPoint(x: 0.38031 * width, y: 0.1199 * height),
			control1: CGPoint(x: 0.42073 * width, y: -0.00006 * height),
			control2: CGPoint(x: 0.3804 * width, y: 0.0403 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.40997 * width, y: 0.23513 * height),
			control1: CGPoint(x: 0.38027 * width, y: 0.17436 * height),
			control2: CGPoint(x: 0.39537 * width, y: 0.20526 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.44012 * width, y: 0.35995 * height),
			control1: CGPoint(x: 0.4255 * width, y: 0.26691 * height),
			control2: CGPoint(x: 0.44017 * width, y: 0.29693 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.4601 * width, y: 0.37997 * height),
			control1: CGPoint(x: 0.44011 * width, y: 0.37099 * height),
			control2: CGPoint(x: 0.44905 * width, y: 0.37996 * height)
		)
		path.addLine(to: CGPoint(x: 0.54009 * width, y: 0.38003 * height))
		path.addCurve(
			to: CGPoint(x: 0.54775 * width, y: 0.37853 * height),
			control1: CGPoint(x: 0.54281 * width, y: 0.38003 * height),
			control2: CGPoint(x: 0.54539 * width, y: 0.3795 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.56011 * width, y: 0.36005 * height),
			control1: CGPoint(x: 0.555 * width, y: 0.37553 * height),
			control2: CGPoint(x: 0.5601 * width, y: 0.36838 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.59047 * width, y: 0.23527 * height),
			control1: CGPoint(x: 0.56016 * width, y: 0.29702 * height),
			control2: CGPoint(x: 0.57488 * width, y: 0.26703 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.62032 * width, y: 0.1201 * height),
			control1: CGPoint(x: 0.60512 * width, y: 0.20542 * height),
			control2: CGPoint(x: 0.62027 * width, y: 0.17456 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.50042 * width, y: 0),
			control1: CGPoint(x: 0.62037 * width, y: 0.04047 * height),
			control2: CGPoint(x: 0.58003 * width, y: 0.00007 * height)
		)
		path.closeSubpath()
		path.move(to: CGPoint(x: 0.5016 * width, y: 0.3687 * height))
		path.addCurve(
			to: CGPoint(x: 0.48452 * width, y: 0.25933 * height),
			control1: CGPoint(x: 0.48081 * width, y: 0.31851 * height),
			control2: CGPoint(x: 0.48261 * width, y: 0.28976 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.47021 * width, y: 0.15776 * height),
			control1: CGPoint(x: 0.48632 * width, y: 0.23072 * height),
			control2: CGPoint(x: 0.48818 * width, y: 0.20114 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.33504 * width, y: 0.10177 * height),
			control1: CGPoint(x: 0.44395 * width, y: 0.09435 * height),
			control2: CGPoint(x: 0.39845 * width, y: 0.07553 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.27906 * width, y: 0.23694 * height),
			control1: CGPoint(x: 0.27163 * width, y: 0.12804 * height),
			control2: CGPoint(x: 0.25279 * width, y: 0.17352 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.34076 * width, y: 0.31887 * height),
			control1: CGPoint(x: 0.29702 * width, y: 0.28032 * height),
			control2: CGPoint(x: 0.31925 * width, y: 0.29991 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.40603 * width, y: 0.4083 * height),
			control1: CGPoint(x: 0.36363 * width, y: 0.33904 * height),
			control2: CGPoint(x: 0.38523 * width, y: 0.3581 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.42197 * width, y: 0.41894 * height),
			control1: CGPoint(x: 0.40878 * width, y: 0.41493 * height),
			control2: CGPoint(x: 0.4152 * width, y: 0.41894 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.42856 * width, y: 0.41762 * height),
			control1: CGPoint(x: 0.42416 * width, y: 0.41894 * height),
			control2: CGPoint(x: 0.4264 * width, y: 0.41851 * height)
		)
		path.addLine(to: CGPoint(x: 0.49227 * width, y: 0.39123 * height))
		path.addCurve(
			to: CGPoint(x: 0.5016 * width, y: 0.3687 * height),
			control1: CGPoint(x: 0.50107 * width, y: 0.38758 * height),
			control2: CGPoint(x: 0.50524 * width, y: 0.3775 * height)
		)
		path.closeSubpath()
		path.move(to: CGPoint(x: 0.72094 * width, y: 0.76305 * height))
		path.addCurve(
			to: CGPoint(x: 0.65924 * width, y: 0.68112 * height),
			control1: CGPoint(x: 0.70297 * width, y: 0.71968 * height),
			control2: CGPoint(x: 0.68074 * width, y: 0.70008 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.59397 * width, y: 0.5917 * height),
			control1: CGPoint(x: 0.63636 * width, y: 0.66095 * height),
			control2: CGPoint(x: 0.61476 * width, y: 0.6419 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.57144 * width, y: 0.58237 * height),
			control1: CGPoint(x: 0.59032 * width, y: 0.58291 * height),
			control2: CGPoint(x: 0.58022 * width, y: 0.57871 * height)
		)
		path.addLine(to: CGPoint(x: 0.50773 * width, y: 0.60877 * height))
		path.addCurve(
			to: CGPoint(x: 0.4984 * width, y: 0.63129 * height),
			control1: CGPoint(x: 0.49893 * width, y: 0.61241 * height),
			control2: CGPoint(x: 0.49475 * width, y: 0.6225 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.51547 * width, y: 0.74067 * height),
			control1: CGPoint(x: 0.51919 * width, y: 0.68148 * height),
			control2: CGPoint(x: 0.51738 * width, y: 0.71023 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.52979 * width, y: 0.84224 * height),
			control1: CGPoint(x: 0.51368 * width, y: 0.76927 * height),
			control2: CGPoint(x: 0.51182 * width, y: 0.79886 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.61407 * width, y: 0.9097 * height),
			control1: CGPoint(x: 0.5484 * width, y: 0.88716 * height),
			control2: CGPoint(x: 0.57664 * width, y: 0.9097 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.66495 * width, y: 0.89822 * height),
			control1: CGPoint(x: 0.62949 * width, y: 0.9097 * height),
			control2: CGPoint(x: 0.64646 * width, y: 0.90588 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.72094 * width, y: 0.76305 * height),
			control1: CGPoint(x: 0.72836 * width, y: 0.87196 * height),
			control2: CGPoint(x: 0.7472 * width, y: 0.82648 * height)
		)
		path.closeSubpath()
		path.move(to: CGPoint(x: 0.41762 * width, y: 0.57144 * height))
		path.addLine(to: CGPoint(x: 0.39123 * width, y: 0.50772 * height))
		path.addCurve(
			to: CGPoint(x: 0.3687 * width, y: 0.4984 * height),
			control1: CGPoint(x: 0.38759 * width, y: 0.49893 * height),
			control2: CGPoint(x: 0.37751 * width, y: 0.49475 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.25933 * width, y: 0.51547 * height),
			control1: CGPoint(x: 0.31852 * width, y: 0.51919 * height),
			control2: CGPoint(x: 0.28978 * width, y: 0.51738 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.15776 * width, y: 0.52978 * height),
			control1: CGPoint(x: 0.23072 * width, y: 0.51368 * height),
			control2: CGPoint(x: 0.20114 * width, y: 0.51182 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.10177 * width, y: 0.66495 * height),
			control1: CGPoint(x: 0.09435 * width, y: 0.55606 * height),
			control2: CGPoint(x: 0.07552 * width, y: 0.60153 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.18606 * width, y: 0.73242 * height),
			control1: CGPoint(x: 0.12038 * width, y: 0.70987 * height),
			control2: CGPoint(x: 0.14862 * width, y: 0.73242 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.23694 * width, y: 0.72094 * height),
			control1: CGPoint(x: 0.20147 * width, y: 0.73242 * height),
			control2: CGPoint(x: 0.21845 * width, y: 0.7286 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.31887 * width, y: 0.65924 * height),
			control1: CGPoint(x: 0.28032 * width, y: 0.70297 * height),
			control2: CGPoint(x: 0.29991 * width, y: 0.68074 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.4083 * width, y: 0.59397 * height),
			control1: CGPoint(x: 0.33904 * width, y: 0.63636 * height),
			control2: CGPoint(x: 0.3581 * width, y: 0.61476 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.41762 * width, y: 0.57144 * height),
			control1: CGPoint(x: 0.41709 * width, y: 0.59032 * height),
			control2: CGPoint(x: 0.42127 * width, y: 0.58023 * height)
		)
		path.closeSubpath()
		path.move(to: CGPoint(x: 0.89823 * width, y: 0.33504 * height))
		path.addCurve(
			to: CGPoint(x: 0.76306 * width, y: 0.27906 * height),
			control1: CGPoint(x: 0.87198 * width, y: 0.27163 * height),
			control2: CGPoint(x: 0.82652 * width, y: 0.25279 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.68112 * width, y: 0.34076 * height),
			control1: CGPoint(x: 0.71968 * width, y: 0.29702 * height),
			control2: CGPoint(x: 0.70008 * width, y: 0.31926 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.5917 * width, y: 0.40603 * height),
			control1: CGPoint(x: 0.66095 * width, y: 0.36363 * height),
			control2: CGPoint(x: 0.6419 * width, y: 0.38524 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.58237 * width, y: 0.42856 * height),
			control1: CGPoint(x: 0.58291 * width, y: 0.40967 * height),
			control2: CGPoint(x: 0.57873 * width, y: 0.41976 * height)
		)
		path.addLine(to: CGPoint(x: 0.60877 * width, y: 0.49227 * height))
		path.addCurve(
			to: CGPoint(x: 0.6247 * width, y: 0.50292 * height),
			control1: CGPoint(x: 0.61152 * width, y: 0.4989 * height),
			control2: CGPoint(x: 0.61794 * width, y: 0.50292 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.6313 * width, y: 0.5016 * height),
			control1: CGPoint(x: 0.6269 * width, y: 0.50292 * height),
			control2: CGPoint(x: 0.62913 * width, y: 0.50249 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.74067 * width, y: 0.48452 * height),
			control1: CGPoint(x: 0.68149 * width, y: 0.48082 * height),
			control2: CGPoint(x: 0.71026 * width, y: 0.48263 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.84224 * width, y: 0.47021 * height),
			control1: CGPoint(x: 0.76927 * width, y: 0.48632 * height),
			control2: CGPoint(x: 0.79887 * width, y: 0.48818 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.89823 * width, y: 0.33504 * height),
			control1: CGPoint(x: 0.90565 * width, y: 0.44394 * height),
			control2: CGPoint(x: 0.92448 * width, y: 0.39846 * height)
		)
		path.closeSubpath()
		path.move(to: CGPoint(x: 0.4083 * width, y: 0.40603 * height))
		path.addCurve(
			to: CGPoint(x: 0.31887 * width, y: 0.34076 * height),
			control1: CGPoint(x: 0.35809 * width, y: 0.38523 * height),
			control2: CGPoint(x: 0.33904 * width, y: 0.36363 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.23694 * width, y: 0.27906 * height),
			control1: CGPoint(x: 0.29991 * width, y: 0.31926 * height),
			control2: CGPoint(x: 0.28032 * width, y: 0.29702 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.10177 * width, y: 0.33504 * height),
			control1: CGPoint(x: 0.17348 * width, y: 0.25277 * height),
			control2: CGPoint(x: 0.12803 * width, y: 0.27163 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.15776 * width, y: 0.47021 * height),
			control1: CGPoint(x: 0.07552 * width, y: 0.39846 * height),
			control2: CGPoint(x: 0.09435 * width, y: 0.44394 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.25933 * width, y: 0.48452 * height),
			control1: CGPoint(x: 0.20112 * width, y: 0.48817 * height),
			control2: CGPoint(x: 0.2307 * width, y: 0.48634 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.3687 * width, y: 0.5016 * height),
			control1: CGPoint(x: 0.28975 * width, y: 0.48261 * height),
			control2: CGPoint(x: 0.3185 * width, y: 0.48081 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.37529 * width, y: 0.50292 * height),
			control1: CGPoint(x: 0.37087 * width, y: 0.50249 * height),
			control2: CGPoint(x: 0.3731 * width, y: 0.50292 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.39123 * width, y: 0.49227 * height),
			control1: CGPoint(x: 0.38206 * width, y: 0.50292 * height),
			control2: CGPoint(x: 0.38848 * width, y: 0.4989 * height)
		)
		path.addLine(to: CGPoint(x: 0.41762 * width, y: 0.42856 * height))
		path.addCurve(
			to: CGPoint(x: 0.4083 * width, y: 0.40603 * height),
			control1: CGPoint(x: 0.42127 * width, y: 0.41976 * height),
			control2: CGPoint(x: 0.41709 * width, y: 0.40968 * height)
		)
		path.closeSubpath()
		path.move(to: CGPoint(x: 0.84224 * width, y: 0.52978 * height))
		path.addCurve(
			to: CGPoint(x: 0.74067 * width, y: 0.51547 * height),
			control1: CGPoint(x: 0.79888 * width, y: 0.51182 * height),
			control2: CGPoint(x: 0.76932 * width, y: 0.51367 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.63129 * width, y: 0.4984 * height),
			control1: CGPoint(x: 0.71024 * width, y: 0.51738 * height),
			control2: CGPoint(x: 0.6815 * width, y: 0.51919 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.60877 * width, y: 0.50772 * height),
			control1: CGPoint(x: 0.62247 * width, y: 0.49475 * height),
			control2: CGPoint(x: 0.61241 * width, y: 0.49893 * height)
		)
		path.addLine(to: CGPoint(x: 0.58237 * width, y: 0.57144 * height))
		path.addCurve(
			to: CGPoint(x: 0.5917 * width, y: 0.59396 * height),
			control1: CGPoint(x: 0.57873 * width, y: 0.58023 * height),
			control2: CGPoint(x: 0.5829 * width, y: 0.59032 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.68112 * width, y: 0.65923 * height),
			control1: CGPoint(x: 0.6419 * width, y: 0.61476 * height),
			control2: CGPoint(x: 0.66095 * width, y: 0.63636 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.76306 * width, y: 0.72093 * height),
			control1: CGPoint(x: 0.70008 * width, y: 0.68074 * height),
			control2: CGPoint(x: 0.71968 * width, y: 0.70297 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.81394 * width, y: 0.73242 * height),
			control1: CGPoint(x: 0.78156 * width, y: 0.7286 * height),
			control2: CGPoint(x: 0.79852 * width, y: 0.73242 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.89822 * width, y: 0.66495 * height),
			control1: CGPoint(x: 0.85137 * width, y: 0.73242 * height),
			control2: CGPoint(x: 0.87962 * width, y: 0.70986 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.84224 * width, y: 0.52978 * height),
			control1: CGPoint(x: 0.92448 * width, y: 0.60153 * height),
			control2: CGPoint(x: 0.90565 * width, y: 0.55606 * height)
		)
		path.closeSubpath()
		path.move(to: CGPoint(x: 0.49227 * width, y: 0.60877 * height))
		path.addLine(to: CGPoint(x: 0.42856 * width, y: 0.58237 * height))
		path.addCurve(
			to: CGPoint(x: 0.40603 * width, y: 0.5917 * height),
			control1: CGPoint(x: 0.41973 * width, y: 0.57871 * height),
			control2: CGPoint(x: 0.40968 * width, y: 0.58291 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.34076 * width, y: 0.68112 * height),
			control1: CGPoint(x: 0.38524 * width, y: 0.6419 * height),
			control2: CGPoint(x: 0.36364 * width, y: 0.66095 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.27907 * width, y: 0.76306 * height),
			control1: CGPoint(x: 0.31926 * width, y: 0.70008 * height),
			control2: CGPoint(x: 0.29704 * width, y: 0.71968 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.26944 * width, y: 0.83288 * height),
			control1: CGPoint(x: 0.2719 * width, y: 0.78036 * height),
			control2: CGPoint(x: 0.2631 * width, y: 0.80643 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.33505 * width, y: 0.89823 * height),
			control1: CGPoint(x: 0.27618 * width, y: 0.861 * height),
			control2: CGPoint(x: 0.29826 * width, y: 0.88299 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.38592 * width, y: 0.90971 * height),
			control1: CGPoint(x: 0.35355 * width, y: 0.90589 * height),
			control2: CGPoint(x: 0.37051 * width, y: 0.90971 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.47021 * width, y: 0.84224 * height),
			control1: CGPoint(x: 0.42335 * width, y: 0.90971 * height),
			control2: CGPoint(x: 0.4516 * width, y: 0.88715 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.48453 * width, y: 0.74067 * height),
			control1: CGPoint(x: 0.48818 * width, y: 0.79886 * height),
			control2: CGPoint(x: 0.48632 * width, y: 0.76928 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.5016 * width, y: 0.6313 * height),
			control1: CGPoint(x: 0.48261 * width, y: 0.71024 * height),
			control2: CGPoint(x: 0.48081 * width, y: 0.68149 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.49227 * width, y: 0.60877 * height),
			control1: CGPoint(x: 0.50524 * width, y: 0.6225 * height),
			control2: CGPoint(x: 0.50107 * width, y: 0.61241 * height)
		)
		path.closeSubpath()
		path.move(to: CGPoint(x: 0.66495 * width, y: 0.10177 * height))
		path.addCurve(
			to: CGPoint(x: 0.52978 * width, y: 0.15776 * height),
			control1: CGPoint(x: 0.60148 * width, y: 0.07549 * height),
			control2: CGPoint(x: 0.55606 * width, y: 0.09436 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.51547 * width, y: 0.25933 * height),
			control1: CGPoint(x: 0.51182 * width, y: 0.20114 * height),
			control2: CGPoint(x: 0.51368 * width, y: 0.23072 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.49839 * width, y: 0.3687 * height),
			control1: CGPoint(x: 0.51738 * width, y: 0.28976 * height),
			control2: CGPoint(x: 0.51918 * width, y: 0.31851 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.50772 * width, y: 0.39123 * height),
			control1: CGPoint(x: 0.49475 * width, y: 0.3775 * height),
			control2: CGPoint(x: 0.49892 * width, y: 0.38758 * height)
		)
		path.addLine(to: CGPoint(x: 0.57144 * width, y: 0.41762 * height))
		path.addCurve(
			to: CGPoint(x: 0.57803 * width, y: 0.41894 * height),
			control1: CGPoint(x: 0.5736 * width, y: 0.41851 * height),
			control2: CGPoint(x: 0.57583 * width, y: 0.41894 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.59396 * width, y: 0.40829 * height),
			control1: CGPoint(x: 0.5848 * width, y: 0.41894 * height),
			control2: CGPoint(x: 0.59121 * width, y: 0.41493 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.65923 * width, y: 0.31887 * height),
			control1: CGPoint(x: 0.61476 * width, y: 0.35809 * height),
			control2: CGPoint(x: 0.63636 * width, y: 0.33904 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.72093 * width, y: 0.23694 * height),
			control1: CGPoint(x: 0.68074 * width, y: 0.29991 * height),
			control2: CGPoint(x: 0.70297 * width, y: 0.28031 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.66495 * width, y: 0.10177 * height),
			control1: CGPoint(x: 0.7472 * width, y: 0.17352 * height),
			control2: CGPoint(x: 0.72836 * width, y: 0.12804 * height)
		)
		path.closeSubpath()
		path.addEllipse(in: CGRect(x: 0.41382 * width, y: 0.41381 * height, width: 0.17237 * width, height: 0.17237 * height))
		path.move(to: CGPoint(x: 0.50017 * width, y: 0.62992 * height))
		path.addCurve(
			to: CGPoint(x: 0.37997 * width, y: 0.54972 * height),
			control1: CGPoint(x: 0.44917 * width, y: 0.62992 * height),
			control2: CGPoint(x: 0.40067 * width, y: 0.5997 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.45028 * width, y: 0.37996 * height),
			control1: CGPoint(x: 0.35255 * width, y: 0.48353 * height),
			control2: CGPoint(x: 0.3841 * width, y: 0.40738 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.62003 * width, y: 0.45028 * height),
			control1: CGPoint(x: 0.51646 * width, y: 0.35257 * height),
			control2: CGPoint(x: 0.5926 * width, y: 0.3841 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.62003 * width, y: 0.45028 * height),
			control1: CGPoint(x: 0.62003 * width, y: 0.45028 * height),
			control2: CGPoint(x: 0.62003 * width, y: 0.45028 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.54972 * width, y: 0.62003 * height),
			control1: CGPoint(x: 0.64744 * width, y: 0.51646 * height),
			control2: CGPoint(x: 0.6159 * width, y: 0.59261 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.50017 * width, y: 0.62992 * height),
			control1: CGPoint(x: 0.53351 * width, y: 0.62674 * height),
			control2: CGPoint(x: 0.51671 * width, y: 0.62992 * height)
		)
		path.closeSubpath()
		path.move(to: CGPoint(x: 0.49988 * width, y: 0.41379 * height))
		path.addCurve(
			to: CGPoint(x: 0.467 * width, y: 0.42035 * height),
			control1: CGPoint(x: 0.48891 * width, y: 0.41379 * height),
			control2: CGPoint(x: 0.47776 * width, y: 0.4159 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.42035 * width, y: 0.53299 * height),
			control1: CGPoint(x: 0.4231 * width, y: 0.43854 * height),
			control2: CGPoint(x: 0.40217 * width, y: 0.48908 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.53299 * width, y: 0.57965 * height),
			control1: CGPoint(x: 0.43853 * width, y: 0.57688 * height),
			control2: CGPoint(x: 0.48901 * width, y: 0.59783 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.57965 * width, y: 0.46701 * height),
			control1: CGPoint(x: 0.5769 * width, y: 0.56146 * height),
			control2: CGPoint(x: 0.59783 * width, y: 0.51092 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.49988 * width, y: 0.41379 * height),
			control1: CGPoint(x: 0.56591 * width, y: 0.43385 * height),
			control2: CGPoint(x: 0.53372 * width, y: 0.41379 * height)
		)
		path.closeSubpath()
		path.move(to: CGPoint(x: 0.4721 * width, y: 0.53298 * height))
		path.addCurve(
			to: CGPoint(x: 0.51874 * width, y: 0.42037 * height),
			control1: CGPoint(x: 0.45388 * width, y: 0.489 * height),
			control2: CGPoint(x: 0.47476 * width, y: 0.43859 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.52592 * width, y: 0.41821 * height),
			control1: CGPoint(x: 0.5211 * width, y: 0.41939 * height),
			control2: CGPoint(x: 0.52353 * width, y: 0.41897 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.46702 * width, y: 0.42037 * height),
			control1: CGPoint(x: 0.50723 * width, y: 0.41228 * height),
			control2: CGPoint(x: 0.48655 * width, y: 0.41228 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.42037 * width, y: 0.53298 * height),
			control1: CGPoint(x: 0.42304 * width, y: 0.43859 * height),
			control2: CGPoint(x: 0.40216 * width, y: 0.489 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.52579 * width, y: 0.58178 * height),
			control1: CGPoint(x: 0.43761 * width, y: 0.57459 * height),
			control2: CGPoint(x: 0.48363 * width, y: 0.59509 * height)
		)
		path.addCurve(
			to: CGPoint(x: 0.4721 * width, y: 0.53298 * height),
			control1: CGPoint(x: 0.50241 * width, y: 0.57436 * height),
			control2: CGPoint(x: 0.48222 * width, y: 0.55742 * height)
		)
		path.closeSubpath()
		return path
	}
}
