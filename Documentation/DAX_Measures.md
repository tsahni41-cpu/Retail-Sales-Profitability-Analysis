# DAX Measures

## Total Revenue
```DAX
Total Revenue = SUM(Sales[Revenue])
```

## Total Profit
```DAX
Total Profit = SUM(Sales[Profit])
```

## Total Orders
```DAX
Total Orders = DISTINCTCOUNT(Sales[Order ID])
```

## Total Customers
```DAX
Total Customers = DISTINCTCOUNT(Sales[Customer ID])
```

## Average Order Value
```DAX
Average Order Value = DIVIDE([Total Revenue], [Total Orders])
```

## Profit Margin
```DAX
Profit Margin = DIVIDE([Total Profit], [Total Revenue])
```

## Average Revenue per Customer
```DAX
Average Revenue per Customer = DIVIDE([Total Revenue], [Total Customers])
```

## Average Profit per Order
```DAX
Average Profit per Order = DIVIDE([Total Profit], [Total Orders])
```
