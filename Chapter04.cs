
static void Main(string[] args)

double balance, interestRate, targetBalance;

	Console.writeline("What is your current balance?");
	balance = convert.todouble(console.readline());

	console.writeline("What is your current annual interest rate (in %)?");
	interestRate = 1 + convert.todouble(console.readline()) / 100.0;

	console.writeline("What balance would you like to have?");
	targetBalance = convert.todouble(console.readline());

int totalYears = 0;
	do
	{
		balance *= interestRate;
		++totalYears;
	}
	while
		(balance < targetBalance);
	console.writeline("In {0} year{1} you'll have a balance of {2}.", totalYears, totalYears == 1 ? "" : "s", balance);
	console.readkey();
	}
