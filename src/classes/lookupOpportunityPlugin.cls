global class lookupOpportunityPlugin implements Process.Plugin { 

   global Process.PluginResult invoke(Process.PluginRequest request) { 
       String opportunityId = (String) request.inputParameters.get('OpportunityId');
       System.debug('opportunityId -> '+opportunityId);
       Map<String, Object> result = new Map<String,Object>();
       result.put('OpportunityId', opportunityId);
       List<Opportunity> oppty = [SELECT Id, Name, Amount, StageName FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
       System.debug('oppty -'+oppty);
       return new Process.PluginResult(result);
   }

   global Process.PluginDescribeResult describe() { 
      Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
      result.Name = 'Look Up Opportunity By Id';
      result.Tag = 'Opportunity Classes';
      
      result.inputParameters = new 
         List<Process.PluginDescribeResult.InputParameter>{ 
            new Process.PluginDescribeResult.InputParameter('OpportunityId', 
            Process.PluginDescribeResult.ParameterType.STRING, true) 
         }; 
      result.outputParameters = new 
         List<Process.PluginDescribeResult.OutputParameter>{              
            new Process.PluginDescribeResult.OutputParameter('error', 
            Process.PluginDescribeResult.ParameterType.STRING)
      }; 
      return result; 
   }
}