global class lookUpAccountPlugin implements Process.Plugin { 

   global Process.PluginResult invoke(Process.PluginRequest request) { 
       String name = (String) request.inputParameters.get('SampleInfo');
       String accountNumber = (String) request.inputParameters.get('AccountNumber');
       System.debug('Name - '+name+' accountNumber -> '+accountNumber);
       /*
       Account account = [SELECT Id FROM Account WHERE Name = :name LIMIT 1][0];
       */
       Map<String,Object> result = new Map<String,Object>();
       result.put('accountId', '1234');
       return new Process.PluginResult(result);
   }

   global Process.PluginDescribeResult describe() { 
      Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
      result.Name = 'Look Up Account ID By Name';
      result.Tag = 'Account Classes';
      result.inputParameters = new 
         List<Process.PluginDescribeResult.InputParameter>{ 
            new Process.PluginDescribeResult.InputParameter('SampleInfo', 
            Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('AccountNumber', 
            Process.PluginDescribeResult.ParameterType.STRING, true) 
         }; 
      result.outputParameters = new 
         List<Process.PluginDescribeResult.OutputParameter>{              
            new Process.PluginDescribeResult.OutputParameter('accountId', 
            Process.PluginDescribeResult.ParameterType.STRING)
                }; 
      return result; 
   }
}