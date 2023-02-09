// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Crowdfunding {
    struct Campaign{
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        string image;
        address[] donators;
        uint256[] donations;
    }

    mapping(uint256=>Campaign) public campaigns;

    uint256 public numberOfCampaigns=0;

    function createCampaign(address _owner,string memory _title, string memory _description, uint256 _target, uint256 _deadline, string memory _image) public returns (uint256){
        Campaign storage campaign=campaigns[numberOfCampaigns];//create a new campaign

        //is everything okay
        require(campaign.deadline<block.timestamp, "The deadline should be a date in future");

        campaign.owner=_owner;//adding data to the campaign
        campaign.title=_title;
        campaign.description=_description;
        campaign.target=_target;
        campaign.deadline=_deadline;
        campaign.amountCollected=0;
        campaign.image=_image;
        
        numberOfCampaigns++;//increasing the no of campaigns so that when net campaign comes it will be stored in next position of campaigns array.

        return numberOfCampaigns-1;//index of most newly created campaign
    }

    function donateToCampaign(uint256 _id)public payable{//id who wants to pay in the campaign
        uint256 amount=msg.value;//amount tha we are tryig to send from frontend

        Campaign storage campaign=campaigns[_id];//getting campaign that we want to donate. campaigns is the mapping we created above

        campaign.donators.push(msg.sender);//pushing address of donatorer to campaign
        campaign.donations.push(amount);//pushing amount to the donations of the campaign

        (bool sent,)=payable(campaign.owner).call{value:amount}("");//variable to check if the transcation is sent or not. Syntax is like this only.
        if(sent){//if transaction is sent
            campaign.amountCollected=campaign.amountCollected+amount;//add amount to the campaign
        }
    }

    function getDonators(uint256 _id) view public returns (address[] memory,uint256[] memory){//fetch the donators who donated in the campaign. it return array of donators and array of donations
        return (campaigns[_id].donators,campaigns[_id].donations);
    }

    function getCampaigns()public view returns (Campaign[] memory){//return all campaigns
        Campaign[] memory allCampaigns=new Campaign[](numberOfCampaigns);//we are a new variable allCampaigns which is of type array of multiple Campaigns struct. we here are not getting campaigns whereas we are creating an empty array of total no of campaigns of empty campaign struct
        for(uint i=0;i<numberOfCampaigns;i++){
            Campaign storage item=campaigns[i];//getting campaign from storage
            allCampaigns[i]=item;//adding that camapigns to our storage
        }
        return allCampaigns;
    }
}